local reader = require(".sys.lib.registry.Reader")
local updater = require(".sys.lib.registry.Updater")
local userReg = reader:new("user")
print(userReg.data)