local kernel = nil
local expect = require "cc.expect"
local class = require ".class"
local usrSrv = {}
local curUsr = 'NeULi'
local userAccs = {}
local usrexist = {}
local permFlags = {sys=1,admin=2,locked=4,pswChng=8,temporary=16}

--- @module users
local users = {}
users.permFlags=permFlags

--- gets curent user id
--- @return number curent user
function users.getuid()
    return curUsr
end
function users.getShortName(uid)
    return userAccs[uid].name
    
end
function users.changePsw(uid,psw)
    if curUsr == uid then
        
    else
        
    end
end
function users.exists(user)
    local u = usrexist[user] or "NeULi"
    if bit.band(userAccs[u].perms,permFlags.locked) == permFlags.locked then
        return false
    end
    return u
end
function users.login(uid,psw)
    expect(1, uid, "string")
    expect(2, psw, "string")
    local usr = userAccs[uid]
    if usr then
        if usr.psw == psw then
            curUsr = uid
            return true
        else
            printError("incorect pasword")
        end
    else
        printError("unknown user")
    end
    return false
end


--- @class user
users.user = class({constructor = function(self,uid,name,psw,home,perms)
    self.uid = uid
    self.name = name
    self.psw = psw
    self.home = home
    self.perms = perms or 0
end})



local function loader()
    local f = kernel.FSIO.io.open("/etc/users","r")
    local usrs = textutils.unserialiseJSON(f:read())
    f:close()
    for uid, value in pairs(usrs) do
        userAccs[uid] = users.user:new(uid,value.user,value.psw,value.home,value.perms)
        usrexist[value.user] = uid
    end
end
local function saver()
    local out = {}
    for uid, usr in pairs(userAccs) do
        out[uid] = {user=usr.name,psw=usr.psw,home=usr.home,perms=usr.perms}
    end
    local f = kernel.FSIO.io.open("/etc/users","w")
    f:write(textutils.serialiseJSON(out))
    f:close()
end

local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function users.new(name,psw,perms)
    if usrexist[name] then
        print("\x1B[31mUser exists\x1b[0m")
        return 1
    end
    if bit.band(userAccs[curUsr].perms,permFlags.admin) ~= 0 then
        if (bit.band(perms,permFlags.sys) ==0) then
            local uid = uuid()
            userAccs[uid] = users.user:new(uid,name,psw,"/home/"..name,perms)
            saver()
        end
    else
        print("\x1B[31mNot enough perms\x1b[0m")
    end
    
end



local config = setmetatable({
    user = function(uid,user,psw,home)
        userAccs[uid] = users.user:new(uid,user,psw,home)
        usrexist[user] = uid
    end
}, {__index = _ENV})





--- E
--- @note e e
---    E
function usrSrv.load()
    _G.users = users
    --local fn, err = loadfile("/users.lua", "t", config)
    --if not fn then
    --    kernel.panic(0x0001)
    --end
    --local ok, err = pcall(fn)
    --if not ok then
    --    kernel.panic(0x0002)
    --end
    --saver()
    loader()

end


function usrSrv.unload()
    _G.users = nil
end

return function(Kernel)
    kernel = Kernel
    return usrSrv
end