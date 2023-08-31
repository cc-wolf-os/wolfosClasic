local args = {...}
local pretty_print = require("cc.pretty").pretty_print
local function file(repo,filename)
    local request = http.get("https://raw.githubusercontent.com/"..repo)
    local f,e = fs.open("/ccpac/"..filename,"w")
    if f == nil then
        printError(e)
        return
    end
    f.write(request.readAll())
    f.close()
    print(("Package %s Installed"):format(filename))

end
local function dim(repo,name)
    if not fs.exists("/ccpac/dim.lua") then
        print(("Package dim missing...\n\tDownloading..."):format(name))
        local packages = require ".ccpac.CraftOS"
        local P = packages.dim
        local Repo = P.loc:format("main")
        file(Repo,P.filename)
    end
    local request = http.get("https://raw.githubusercontent.com/"..repo)
    local f,e = fs.open("/ccpac/tmp.dim","w")
    if f == nil then
        printError(e)
        return
    end
    f.write(request.readAll())
    f.close()
    print(("Package %s Downloaded"):format(name))
    local Dim = require ".ccpac.dim"
    local Dd = Dim.file:new("/ccpac/tmp.dim")
    if not fs.exists("/ccpac/"..name) then
        fs.makeDir("/ccpac/"..name)
    end
    Dd:save("/ccpac/"..name,2)
    fs.delete("/ccpac/tmp.dim")
    print(("Package %s Installed"):format(name))

end
local function install(pkg,br)
    local packages = require ".ccpac.index"
    for c,pkgtbl in pairs(packages) do
        if pkgtbl[pkg] then
            local p = pkgtbl[pkg]
            if p.pt == "file" then
                local repo = p.loc:format(br)
                file(repo,p.filename)
                return
            elseif p.pt == "dim" then
                local repo = p.loc:format(br)
                dim(repo,pkg)
                return
            end
        end
    end
    print(("Package %s does not exist"):format(pkg))
end
if #args == 0 then
    print([[CCPac by Badgeminer2
    refresh                         | refreshes package table
    install <package> [branch]      | installs package
    remove <package>                | removes package
    build-package <name> <folder>   | builds a .dim package]])
else
    if args[1] == "refresh" then
        local request = http.get("https://raw.githubusercontent.com/CCPackages/index/main/index.lua")
        local f,e = fs.open("/ccpac/index.lua","w")
        if f == nil then
            printError(e)
            return
        end
        f.write(request.readAll())
        f.close()
        print("Downloaded package index")
    elseif args[1] == "install" then
        local package = args[2]
        local branch = args[3] or "main"
        install(package,branch)
    elseif args[1] == "remove" then
        local pkg = args[2]
        local packages = require ".ccpac.index"
        for c,pkgtbl in pairs(packages) do
            if pkgtbl[pkg] then
                local p = pkgtbl[pkg]
                if p.pt == "file" then
                    if fs.exists("/ccpac/"..p.filename) then
                        fs.delete("/ccpac/"..p.filename)
                        return
                    else
                        print(("Package %s is not installed"):format(pkg))
                    end
                elseif p.pt == "dim" then
                    if fs.exists("/ccpac/"..pkg) then
                        fs.delete("/ccpac/"..pkg)
                        return
                    else
                        print(("Package %s is not installed"):format(pkg))
                    end
                end
                
            end
        end
        print(("Package %s does not exist or is not installed"):format(pkg))
    elseif args[1] == "build-package" then
        local pkg = args[2]
        local folder = args[3]
        if not fs.exists("/ccpac/dim.lua") then
            print(("Package dim missing...\n\tDownloading..."))
            local packages = require ".ccpac.CraftOS"
            local P = packages.dim
            local Repo = P.loc:format("main")
            file(Repo,P.filename)
        end
    end
end