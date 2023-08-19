local args = {...}
local w,h = term.getSize()
local entries = {
    ["admin"] = users.permFlags.admin,
    ["locked"] = users.permFlags.locked,
    ["prompt to set pasword"] = users.permFlags.pswChng,
    ["temporary"] = users.permFlags.temporary,
}
local entrys = {}
for key, value in pairs(entries) do
    entrys[key] = false
end
if #args > 0 then
    for index, value in ipairs(args) do
        print(index,value)
    end
else
    local curTerm = term.current()
    curTerm.write = writeANSI(curTerm.write)
    local PrimeUI = require ".prime"
    PrimeUI.clear()
    PrimeUI.label(curTerm, 3, 2, "Add User To \x1b[96mWolf\x1b[34mOS")
    PrimeUI.horizontalLine(curTerm, 3, 3, #("Add User To WolfOS") + 2)
    PrimeUI.borderBox(curTerm, 4, 6, w-5, h-10)
    local scroller = PrimeUI.scrollBox(curTerm, 4, 6, w-5, h-10, math.clamp(#entrys,h-10,100), false, true)
    
    PrimeUI.checkSelectionBox(scroller, 1, 1, w-5, h-10, entrys)
    PrimeUI.button(curTerm, 3, h-2, "Next", "done")
    --PrimeUI.keyAction(keys.enter, "done")
    PrimeUI.run()
    local p = 0
    for key, value in pairs(entries) do
        if entrys[key] then
            p = bit.bor(p,value)
        end
    end
    local uname,_ = "NeULi",nil
    while true do
        PrimeUI.clear()
        PrimeUI.label(curTerm, 3, 2, "Add User To \x1b[96mWolf\x1b[34mOS")
        PrimeUI.horizontalLine(curTerm, 3, 3, #("Installing WolfOS") + 2)
        PrimeUI.label(curTerm, 3, 6, "Username")
        PrimeUI.borderBox(curTerm, #("Username")+5, 6, 40, 1)
        PrimeUI.inputBox(curTerm, #("Username")+5, 6, 40, "result")
        _, _, uname = PrimeUI.run()
        if not users.exists(uname) then
            break
        end
    end
    
    PrimeUI.clear()
    PrimeUI.label(curTerm, 3, 2, "Installing WolfOS")
    PrimeUI.horizontalLine(curTerm, 3, 3, #("Installing WolfOS") + 2)
    PrimeUI.label(curTerm, 3, 4, "User: "..uname)
    PrimeUI.label(curTerm, 3, 6, "Pasword")
    PrimeUI.borderBox(curTerm, #("Pasword")+5, 6, 40, 1)
    PrimeUI.inputBox(curTerm, #("Pasword")+5, 6, 40, "result",nil,nil,"\x07")
    local _, _, psw = PrimeUI.run()
    PrimeUI.clear()
    users.new(uname,psw,p)
    
end