local kernel = nil
local sysSrv = {}

--- @module system
local system = {}

--- kills kernel
--- @param code number
function system.kill(code)
    kernel.panic(code)
end

function system.shutdown()
    term.clear()
    term.setCursorPos(1,1)
    print("WolfOS Shuting Down...")
    kernel.shutdown()
end

--- checks if file is Protected
--- @param file string file name
function system.isProtectedFile(file)
    return kernel.isProtectedFile(file)
end




function sysSrv.load()
    _G.system = system
end

function sysSrv.unload()
    _G.system = nil
end

return function(Kernel)
    kernel = Kernel
    return sysSrv
end