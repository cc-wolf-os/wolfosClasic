local prompt = "\\u@\\H"
local function genPrompt()
    local prmpt = prompt
    local prmptSub = {
        ["\\u"]=users.getShortName(users.getuid()),
        ["\\H"]=os.getComputerLabel() or "localhost",
        ["\\c"] = shell.dir()
    }
    for key, value in pairs(prmptSub) do
        prmpt = prmpt:gsub(key,value)
    end
    return prmpt
end
print(genPrompt())