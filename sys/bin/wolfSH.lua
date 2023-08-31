--[[- The shell API provides access to CraftOS's command line interface.
It allows you to @{run|start programs}, @{setCompletionFunction|add completion
for a program}, and much more.
@{shell} is not a "true" API. Instead, it is a standard program, which injects
its API into the programs that it launches. This allows for multiple shells to
run at the same time, but means that the API is not available in the global
environment, and so is unavailable to other @{os.loadAPI|APIs}.
## Programs and the program path
When you run a command with the shell, either from the prompt or
@{shell.run|from Lua code}, the shell API performs several steps to work out
which program to run:
 1. Firstly, the shell attempts to resolve @{shell.aliases|aliases}. This allows
    us to use multiple names for a single command. For example, the `list`
    program has two aliases: `ls` and `dir`. When you write `ls /rom`, that's
    expanded to `list /rom`.
 2. Next, the shell attempts to find where the program actually is. For this, it
    uses the @{shell.path|program path}. This is a colon separated list of
    directories, each of which is checked to see if it contains the program.
    `list` or `list.lua` doesn't exist in `.` (the current directory), so she
    shell now looks in `/rom/programs`, where `list.lua` can be found!
 3. Finally, the shell reads the file and checks if the file starts with a
    `#!`. This is a [hashbang][], which says that this file shouldn't be treated
    as Lua, but instead passed to _another_ program, the name of which should
    follow the `#!`.
[hashbang]: https://en.wikipedia.org/wiki/Shebang_(Unix)
@module[module] shell
]]
local make_package = dofile("rom/modules/main/cc/require.lua").make
local USER = users and users.getShortName(users.getuid()) or "root"

local prompt = "\\u@\\H:\\c\\$"
local function genPrompt()
    local prmpt = prompt
    local prmptSub = {
        ["\\u"]=USER,
        ["\\H"]=os.getComputerLabel() or "localhost",
        ["\\%$"] = USER == "root" and "#" or "$",
        ["\\c"] = shell.dir()
    }
    for key, value in pairs(prmptSub) do
        prmpt = prmpt:gsub(key,value)
    end
    return prmpt
end

local multishell = multishell
local parentShell = shell
local parentTerm = term.current()

if multishell then
    multishell.setTitle(multishell.getCurrent(), "shell")
end

local bExit = false
local sDir = parentShell and parentShell.dir() or ""
local sPath = parentShell and parentShell.path()..":/sys/bin:/lib" or ".:/rom/programs"
parentShell.setPath(sPath)
local tAliases = parentShell and parentShell.aliases() or {}
local tCompletionInfo = parentShell and parentShell.getCompletionInfo() or {}
local tProgramStack = {}

--local shell = {} --- @export
local function createShellEnv(dir)
    local env = { shell = shell, multishell = multishell }
    env.require, env.package = make_package(env, dir)
    return env
end

-- Set up a dummy require based on the current shell, for loading some of our internal dependencies.
local require
do
    local env = setmetatable(createShellEnv("/rom/programs"), { __index = _ENV })
    require = env.require
end
local expect = require("cc.expect").expect
local exception = require "cc.internal.exception"

-- Colours
local promptColour, textColour, bgColour,hddr
if term.isColour() then
    hddr = colors.orange
    promptColour = colours.yellow
    textColour = colours.white
    bgColour = colours.black
end

local function tokenise(...)
    local sLine = table.concat({ ... }, " ")
    local tWords = {}
    local bQuoted = false
    for match in string.gmatch(sLine .. "\"", "(.-)\"") do
        if bQuoted then
            table.insert(tWords, match)
        else
            for m in string.gmatch(match, "[^ \t]+") do
                table.insert(tWords, m)
            end
        end
        bQuoted = not bQuoted
    end
    return tWords
end

-- Execute a program using os.run, unless a shebang is present.
-- In that case, execute the program using the interpreter specified in the hashbang.
-- This may occur recursively, up to the maximum number of times specified by remainingRecursion
-- Returns the same type as os.run, which is a boolean indicating whether the program exited successfully.
local function executeProgram(remainingRecursion, path, args)
    local file, err = fs.open(path, "r")
    if not file then
        printError(err)
        return false
    end

    -- First check if the file begins with a #!
    local contents = file.readLine() or ""

    if contents:sub(1, 2) == "#!" then
        file.close()

        remainingRecursion = remainingRecursion - 1
        if remainingRecursion == 0 then
            printError("Hashbang recursion depth limit reached when loading file: " .. path)
            return false
        end

        -- Load the specified hashbang program instead
        local hashbangArgs = tokenise(contents:sub(3))
        local originalHashbangPath = table.remove(hashbangArgs, 1)
        local resolvedHashbangProgram = shell.resolveProgram(originalHashbangPath)
        if not resolvedHashbangProgram then
            printError("Hashbang program not found: " .. originalHashbangPath)
            return false
        elseif resolvedHashbangProgram == "rom/programs/shell.lua" and #hashbangArgs == 0 then
            -- If we try to launch the shell then our shebang expands to "shell <program>", which just does a
            -- shell.run("<program>") again, resulting in an infinite loop. This may still happen (if the user
            -- has a custom shell), but this reduces the risk.
            -- It's a little ugly special-casing this, but it's probably worth warning about.
            printError("Cannot use the shell as a hashbang program")
            return false
        end

        -- Add the path and any arguments to the interpreter's arguments
        table.insert(hashbangArgs, path)
        for _, v in ipairs(args) do
            table.insert(hashbangArgs, v)
        end

        hashbangArgs[0] = originalHashbangPath
        return executeProgram(remainingRecursion, resolvedHashbangProgram, hashbangArgs)
    end

    contents = contents .. "\n" .. (file.readAll() or "")
    file.close()

    local dir = fs.getDir(path)
    local env = setmetatable(createShellEnv(dir), { __index = _G })
    env.arg = args

    local func, err = load(contents, "@/" .. fs.combine(path), nil, env)
    if not func then
        -- We had a syntax error. Attempt to run it through our own parser if
        -- the file is "small enough", otherwise report the original error.
        if #contents < 1024 * 128 then
            local parser = require "cc.internal.syntax"
            if parser.parse_program(contents) then printError(err) end
        else
            printError(err)
        end

        return false
    end

    if settings.get("bios.strict_globals", false) then
        getmetatable(env).__newindex = function(_, name)
            error("Attempt to create global " .. tostring(name), 2)
        end
    end

    local ok, err, co = exception.try(func, table.unpack(args, 1, args.n))

    if ok then return true end

    if err and err ~= "" then
        printError(err)
        exception.report(err, co)
    end

    return false
end



local tArgs = { ... }
if #tArgs > 0 then
    -- "shell x y z"
    -- Run the program specified on the commandline
    shell.run(...)

else
    local function show_prompt()
        term.setBackgroundColor(bgColour)
        term.setTextColour(promptColour)
        write(genPrompt())
        term.setTextColour(textColour)
    end

    -- "shell"
    -- Print the header
    term.setBackgroundColor(bgColour)
    term.setTextColour(hddr)
    print(os.version())
    term.setTextColour(textColour)

    -- Run the startup program
    if parentShell == nil then
        shell.run("/rom/startup.lua")
    end

    -- Read commands and execute them
    local tCommandHistory = {}
    while not bExit do
        term.redirect(parentTerm)
        if term.setGraphicsMode then term.setGraphicsMode(0) end
        show_prompt()


        local complete
        if settings.get("shell.autocomplete") then complete = shell.complete end

        local ok, result
        local co = coroutine.create(read)
        assert(coroutine.resume(co, nil, tCommandHistory, complete))

        while coroutine.status(co) ~= "dead" do
            local event = table.pack(os.pullEvent())
            if event[1] == "file_transfer" then
                -- Abandon the current prompt
                local _, h = term.getSize()
                local _, y = term.getCursorPos()
                if y == h then
                    term.scroll(1)
                    term.setCursorPos(1, y)
                else
                    term.setCursorPos(1, y + 1)
                end
                term.setCursorBlink(false)

                -- Run the import script with the provided files
                local ok, err = require("cc.internal.import")(event[2].getFiles())
                if not ok and err then printError(err) end

                -- And attempt to restore the prompt.
                show_prompt()
                term.setCursorBlink(true)
                event = { "term_resize", n = 1 } -- Nasty hack to force read() to redraw.
            end

            if result == nil or event[1] == result or event[1] == "terminate" then
                ok, result = coroutine.resume(co, table.unpack(event, 1, event.n))
                if not ok then error(result, 0) end
            end
        end
        if result:match("%S") and tCommandHistory[#tCommandHistory] ~= result then
            table.insert(tCommandHistory, result)
        end
        shell.run(result)
        if result == "logout" then
            bExit = true
        end

    end
end
