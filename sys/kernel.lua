local wosV = "0.1"
local FileFlags = {sys=1,edit=2,read=4,exec=8,delete=16}
local GNOME = {
    ["black"]     = 0x111111,
    ["blue"]      = 0x2A7BDE,
    ["brown"]     = 0xA2734C,
    ["cyan"]      = 0x2AA1B3,
    ["gray"]      = 0x444444,
    ["green"]     = 0x26A269,
    ["lightBlue"] = 0x00AEFF,
    ["lightGray"] = 0x777777,
    ["lime"]      = 0x33D17A,
    ["magenta"]   = 0xC061CB,
    ["orange"]    = 0xD06018,
    ["pink"]      = 0xF66151,
    ["purple"]    = 0xA347BA,
    ["red"]       = 0xC01C28,
    ["white"]     = 0xFFFFFF,
    ["yellow"]    = 0xF3F03E
}
--local colorI = log4l.new("/wolfos/logs", 7 --[[Time shift (here, +2 utc)]], nil)
for color, code in pairs(GNOME) do
    _G.term.setPaletteColor(colors[color], code)
    --colorI.info("#"..tostring(string.sub(string.format("%x", code),1,-1)).."  "..color)
end
function os.version()
    return ("Wolf\x1b[34mOS \x1b[96mV%s"):format(wosV)
end
local serv = {}
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.orange)
print(("Wolf\x1b[34mOS \x1b[96m%s"):format(wosV))
term.setTextColor(colors.white)
function table.clone(org)
    return {table.unpack(org)}
  end

local function compress(...)
    return arg
end
local function split(w)
    words = {}
    for word in w:gmatch("%w+") do table.insert(words, word) end
    return words
end
local function Split(w)
    local words = split(w)
    table.remove(words,1)
    return words
end
local function get_keys(t)
    local keys={}
    for key,_ in pairs(t) do
      table.insert(keys, key)
    end
    return keys
  end
local function appendAll(t,s)
    local tbl = {}
    for k,v in pairs(t) do
        tbl[k] = s:format(v)
    end    
    return tbl
end
function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
  end
local expect = require("cc.expect").expect
local function writeANSI(nativewrite)
    return function(str)
        local seq = nil
        local bold = false
        local lines = 0
        local function getnum(d) 
            if seq == "[" then return d or 1
            elseif string.find(seq, ";") then return 
                tonumber(string.sub(seq, 2, string.find(seq, ";") - 1)), 
                tonumber(string.sub(seq, string.find(seq, ";") + 1)) 
            else return tonumber(string.sub(seq, 2)) end 
        end
        for c in string.gmatch(str, ".") do
            if seq == "\27" then
                if c == "c" then
                    term.setBackgroundColor(colors.black)
                    term.setTextColor(colors.white)
                    term.setCursorBlink(true)
                elseif c == "[" then seq = "["
                else seq = nil end
            elseif seq ~= nil and string.sub(seq, 1, 1) == "[" then
                if tonumber(c) ~= nil or c == ';' then seq = seq .. c else
                    if c == "A" then term.setCursorPos(term.getCursorPos(), select(2, term.getCursorPos()) - getnum())
                    elseif c == "B" then term.setCursorPos(term.getCursorPos(), select(2, term.getCursorPos()) + getnum())
                    elseif c == "C" then term.setCursorPos(term.getCursorPos() + getnum(), select(2, term.getCursorPos()))
                    elseif c == "D" then term.setCursorPos(term.getCursorPos() - getnum(), select(2, term.getCursorPos()))
                    elseif c == "E" then term.setCursorPos(1, select(2, term.getCursorPos()) + getnum())
                    elseif c == "F" then term.setCursorPos(1, select(2, term.getCursorPos()) - getnum())
                    elseif c == "G" then term.setCursorPos(getnum(), select(2, term.getCursorPos()))
                    elseif c == "H" then term.setCursorPos(getnum())
                    elseif c == "J" then term.clear() -- ?
                    elseif c == "K" then term.clearLine() -- ?
                    elseif c == "T" then term.scroll(getnum())
                    elseif c == "f" then term.setCursorPos(getnum())
                    elseif c == "m" then
                        local n, m = getnum(0)
                        if n == 0 then
                            term.setBackgroundColor(colors.black)
                            term.setTextColor(colors.white)
                        elseif n == 1 then bold = true
                        elseif n == 7 or n == 27 then
                            local bg = term.getBackgroundColor()
                            term.setBackgroundColor(term.getTextColor())
                            term.setTextColor(bg)
                        elseif n == 22 then bold = false
                        elseif n >= 30 and n <= 37 then term.setTextColor(2^(15 - (n - 30) - (bold and 8 or 0)))
                        elseif n == 39 then term.setTextColor(colors.white)
                        elseif n >= 40 and n <= 47 then term.setBackgroundColor(2^(15 - (n - 40) - (bold and 8 or 0)))
                        elseif n == 49 then term.setBackgroundColor(colors.black) 
                        elseif n >= 90 and n <= 97 then term.setTextColor(2^(15 - (n - 90) - 8))
                        elseif n >= 100 and n <= 107 then term.setBackgroundColor(2^(15 - (n - 100) - 8)) end
                        if m ~= nil then
                            if m == 0 then
                                term.setBackgroundColor(colors.black)
                                term.setTextColor(colors.white)
                            elseif m == 1 then bold = true
                            elseif m == 7 or m == 27 then
                                local bg = term.getBackgroundColor()
                                term.setBackgroundColor(term.getTextColor())
                                term.setTextColor(bg)
                            elseif m == 22 then bold = false
                            elseif m >= 30 and m <= 37 then term.setTextColor(2^(15 - (m - 30) - (bold and 8 or 0)))
                            elseif m == 39 then term.setTextColor(colors.white)
                            elseif m >= 40 and m <= 47 then term.setBackgroundColor(2^(15 - (m - 40) - (bold and 8 or 0)))
                            elseif m == 49 then term.setBackgroundColor(colors.black) 
                            elseif n >= 90 and n <= 97 then term.setTextColor(2^(15 - (n - 90) - 8))
                            elseif n >= 100 and n <= 107 then term.setBackgroundColor(2^(15 - (n - 100) - 8)) end
                        end
                    elseif c == "z" then
                        local n, m = getnum(0)
                        if n == 0 then
                            term.setBackgroundColor(colors.black)
                            term.setTextColor(colors.white)
                        elseif n == 7 or n == 27 then
                            local bg = term.getBackgroundColor()
                            term.setBackgroundColor(term.getTextColor())
                            term.setTextColor(bg)
                        elseif n >= 25 and n <= 39 then term.setTextColor(n-25)
                        elseif n >= 40 and n <= 56 then term.setBackgroundColor(n-40)
                        end
                        if m ~= nil then
                            if m == 0 then
                                term.setBackgroundColor(colors.black)
                                term.setTextColor(colors.white)
                            elseif m == 7 or m == 27 then
                                local bg = term.getBackgroundColor()
                                term.setBackgroundColor(term.getTextColor())
                                term.setTextColor(bg)
                            elseif m >= 25 and m <= 39 then term.setTextColor(m-25)
                            elseif m >= 40 and m <= 56 then term.setBackgroundColor(m-40)
                        end
                    end
                    end
                    seq = nil
                end
            elseif c == string.char(0x1b) then seq = "\27"
            else lines = lines + (nativewrite(c) or 0) end
        end
        return lines
    end
end
_G.write = writeANSI(write)
_G.writeANSI = writeANSI

--- @module kernel
local kernel = {
    userspaceGlobals = {}
}
local blockedFiles = {}

--local config = setmetatable({
--    block = function(file)
--        blockedFiles[file] = true
--    end
--}, {__index = _ENV})

local FS = {
    open = fs.open,
    delete = fs.delete
}
local IO = {
    open = io.open
}
kernel.FSIO = {fs=FS,io=IO}
for i,file in ipairs(fs.list("/srv/")) do
    local f = string.gsub(file,".lua","")
    local s = require(".srv."..f)(kernel)
    s.load()
    table.insert(serv,s)
end 
local function check(p,flg)
    local uid = users.getuid()
    for key, value in pairs(blockedFiles) do
        local found = fs.find(key)
        if bit.band(value[uid] or 4,flg) ~=0 then
            --PASS
        else
            for index, value in ipairs(found) do
                if value == p then
                    return true
                end
            end
        end
    end
    return false
end
_G.check = check
function _G.fs.open(p,m)
    if check(p,FileFlags.edit) and (string.find(m,"w") or string.find(m,"a")) then
        return nil,"Blocked by wolfos"
    end
    return FS.open(p,m)
end
function _G.fs.delete(p)
    if check(p,FileFlags.delete) then
        error("Blocked by wolfos")
        return nil
    end
    return FS.delete(p)
end
function _G.io.open(p,m)
    if check(p,FileFlags.edit) and (string.find(m,"w") or string.find(m,"a")) then
        return nil,"Blocked by wolfos"
    end
    return IO.open(p,m)
end

--- sends kernel into panic
--- @param exitcode integer
function kernel.panic(exitcode)
    -- TODO
    print(([[WolfOS kernel panic
        exitcode %s]]):format(("0x%04X"):format(tostring(exitcode))))
    print("Press any key to shutdown...")
    os.pullEvent("key")
    os.shutdown(exitcode)
end

--- blocks userspace from editing file
--- @param filepath string filename
function kernel.blockFile(filepath)
    -- TODO
end

function kernel.shutdown()
    for index, value in ipairs(serv) do
        value.unload()
    end
    kernel.panic(0)
end

--- checks if file is blocked
--- @param file string filename
function kernel.isProtectedFile(file)
    return blockedFiles[file] or false
end

--local fn, err = loadfile("/config.lua", "t", config)
--if not fn then
--    kernel.panic(0x0001)
--end
--local ok, err = pcall(fn)
--if not ok then
--    kernel.panic(0x0002)
--end


local function loader()
    local f = kernel.FSIO.io.open("/etc/file.meta","r")
    if f == nil then
        kernel.panic(0x0001)
        return 11111
    end
    local meta = textutils.unserialiseJSON(f:read())
    f:close()
    for file, v in pairs(meta.files) do
        blockedFiles[file] = v
    end
end
loader()

local args = ... or  ""

local function kernelTerm()
    local completion = require "cc.completion"
    local commands = { "boot -s","boot optTgl", "kernel -s","kernel reg", "reboot"}
    local boot = settings.get("wolfos.boot",{opt=false})
    while true do
        local cmd = read(nil, nil, function(text)return completion.choice(text, commands)end)
        local t  = split(cmd)
        if t[1] == "boot" then
            if t[2] == "-s" then
                settings.set("wolfos.boot",boot)
                print("saved")
            elseif t[2] == "optTgl" then
                boot.opt = not boot.opt
                print("toggled to "..tostring(boot.opt))
            end
        elseif t[1]=="kernel" then
            if t[2] == "-s" then
                --TODO
                print("saved")
            elseif t[2] == "reg" then
                if t[3] then
                    --TODO
                else
                    print("not enough args")
                end
            end
        elseif t[1]=="reboot" then
            kernel.panic(0)
        end
    end
end




if not term.isColour() then
    kernel.panic(0x0003)
end

local class = require ".class"
local spnnr = class({constructor=function(self,tx,ic)
    self.tx = tx
    self.ic = ic or false
end,blit=function(self,fg,bg)
    if self.ic then
        term.blit(self.tx,tostring(fg),tostring(bg))
    else
        term.blit(self.tx,tostring(bg),tostring(fg))
    end
    
end})

function math.clamp(x, min, max)
    if x < min then return min end
    if x > max then return max end
    return x
end
local loadingSpinner = {spnnr:new("\x92"),spnnr:new("\x8C"),spnnr:new("\x9E",true),spnnr:new("\x92"),spnnr:new("\x8C"),spnnr:new("\x9E",true)}

term.clear()
term.setCursorPos(1,1)
local w,h = term.getSize()
local hW,hH = w/2,h/2
local dl = 1/12

for i = 1, 12, 1 do
    term.setCursorPos(hW,hH)
    loadingSpinner[(i%6)+1]:blit("f","0")
    sleep(dl)
end

term.clear()
if args:find("-k") then
    kernelTerm()
elseif args == "" then
    shell.run("/sys/login.lua")
    sleep(2)
    local bigfont = require ".bigfont"
    term.setBackgroundColor(colors.blue)
    term.clear()
    term.setCursorPos(2,2)
    bigfont.hugePrint(":(")
    print([[ Your PC ran into a problem and needs to restart]])
end
