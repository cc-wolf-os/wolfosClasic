local reader = require(".sys.lib.registry.Reader")
local updater = require(".sys.lib.registry.Updater")
local file = require(".sys.lib.utils.file")

print("Checking for registry updates...")

local function updateRegistry(name)
  local save = ("sys/wm/bin/Registry/%s.json"):format(name)

  if fs.exists(save) then
    local oldReader = reader:new(name)
    local newReader = reader:new(name, true)

    local current = newReader:get("RegistryVersion")
    local old = oldReader:get("RegistryVersion")

    if current > old then
      print("Updating " .. name .. " registry...")

      local currFull = oldReader.data
      local new = newReader.data
      file.writeJSON(save, updater(currFull, new))
      print("Updated " .. name .. " registry to version " .. current)
    end
  else
    print("Creating " .. name .. " registry...")
    local default = reader:new(name, true)
    file.writeJSON(save, updater({}, default.data))
    print("Created " .. name .. " registry")
  end
end

updateRegistry("machine")
updateRegistry("user")

print("Starting window manager...")
shell.run("sys/wm/bin/wm.lua")