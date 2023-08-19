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

local loadingSpinner = {spnnr:new("\x92"),spnnr:new("\x8C"),spnnr:new("\x9E",true),spnnr:new("\x92"),spnnr:new("\x8C"),spnnr:new("\x9E",true)}
local ouline = {}
local PrimeUI = require ".prime"
local curTerm = term.current()
curTerm.write = writeANSI(curTerm.write)
while true do
    --term.clear()
    --term.setCursorPos(1,1)
    local valid = false
    while true do
        PrimeUI.clear()
        PrimeUI.label(curTerm, 3, 2, "\x1b[96mWolf\x1b[34mOS \x1b[96mLogin")
        PrimeUI.horizontalLine(curTerm, 3, 3, #("WolfOS Login") + 2)
        PrimeUI.label(curTerm, 3, 6, "Username")
        PrimeUI.borderBox(curTerm, #("Username")+5, 6, 40, 1)
        PrimeUI.inputBox(curTerm, #("Username")+5, 6, 40, "result")
        local _, _, uname = PrimeUI.run()
        if users.exists(uname) then
            for i = 1,3 do
                PrimeUI.clear()
                PrimeUI.label(curTerm, 3, 2, "\x1b[96mWolf\x1b[34mOS \x1b[96mLogin")
                PrimeUI.horizontalLine(curTerm, 3, 3, #("WolfOS Login") + 2)
                PrimeUI.label(curTerm, 3, 4, "User: "..uname)
                PrimeUI.label(curTerm, 3, 6, "Pasword")
                PrimeUI.borderBox(curTerm, #("Pasword")+5, 6, 40, 1)
                PrimeUI.inputBox(curTerm, #("Pasword")+5, 6, 40, "result",nil,nil,"\x07")
                local _, _, pasword = PrimeUI.run()
                if users.login(users.exists(uname),pasword) then
                    valid = true
                    break
                end
            end
        else
            printError("user does not exist")
        end
        if valid then
            break
        end
    end
    -- TODO
    term.clear()
    term.setCursorPos(1,1)
    local w,h = term.getSize()
    local hW,hH = w/2,h/2
    local dl = 2/24

    for i = 1, 24, 1 do
        term.setCursorPos(hW,hH)
        loadingSpinner[(i%6)+1]:blit("f","0")
        sleep(dl)
    end
    term.clear()
    term.setCursorPos(1,1)
    shell.run("/sys/bin/WolfSH.lua")
end