local kernel = nil
local intrpSrv = {}




function intrpSrv.load()
    local modem = peripheral.find("modem") or printError("No modem attached", 0)
end

function intrpSrv.unload()
end

return function(Kernel)
    kernel = Kernel
    return intrpSrv
end