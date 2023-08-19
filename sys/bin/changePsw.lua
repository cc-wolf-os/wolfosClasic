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
local w,h = term.getSize()
local hW,hH = w/2,h/2
local dl = 2/24
while true do
    --term.clear()
    --term.setCursorPos(1,1)
    local valid = false
    while true do
        PrimeUI.clear()
        PrimeUI.label(curTerm, 3, 2, "\x1b[96mWolf\x1b[34mOS \x1b[0mPasword Change")
        PrimeUI.horizontalLine(curTerm, 3, 3, #("WolfOS Pasword Change") + 2)
        PrimeUI.label(curTerm, 3, 4, "User: "..users.getShortName(users.getuid()))
        PrimeUI.label(curTerm, 3, 6, "Pasword")
        PrimeUI.borderBox(curTerm, #("Pasword")+5, 6, 40, 1)
        PrimeUI.inputBox(curTerm, #("Pasword")+5, 6, 40, "result",nil,nil,"\x07")
        PrimeUI.borderBox(term.current(), 4, 9, w-8, h-11)
        local scroller = PrimeUI.scrollBox(term.current(), 4, 9, w-8, h-11, 9000, true, true)
        PrimeUI.drawText(scroller, [[Your system admin has required a pasword Change]], true)
        local _, _, pasword = PrimeUI.run()
    end
    -- TODO
    term.clear()
    term.setCursorPos(1,1)
    

    for i = 1, 24, 1 do
        term.setCursorPos(hW,hH)
        loadingSpinner[(i%6)+1]:blit("f","0")
        sleep(dl)
    end
    term.clear()
    term.setCursorPos(1,1)
    shell.run("/WolfSH.lua")
end