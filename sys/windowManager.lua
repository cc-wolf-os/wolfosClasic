local pack = require ".sys.lib.pack"
local p = pack.pack:new()
local class = require ".class"
local w,h = term.getSize()
local tbp = h-1
local mainTerm = term.native()
if not mainTerm then
    error("WM: ",999999)
end
local nft = require "cc.image.nft"
local builtinIcons = {
    orangebox = ('\x1E1\x1F%x\x97\x83\x1F1\x1E%x\x94\n\x1F1\x1E%x\x8A\x1E1\x1F0\xDF\x1F1\x1E%x\x85'),
    missing = ('\x1EE\x1F0M\x1F%x\x83\x1F0I\n\x1FE\x1E%x\x8A\x1EE\x1F0\x13\x1FE\x1E%x\x85')
}
local function ix(i)
    return i,i,i,i,i,i,i,i
end
local PW = {}
function PW:constructor(title,cmd,icon)
    self.iconEnbl = nft.parse((icon or builtinIcons.missing):format(ix(0)))
    self.iconIdle = nft.parse((icon or builtinIcons.missing):format(ix(8)))
    self.iconAlert = nft.parse((icon or builtinIcons.missing):format(ix(14)))
    self.active = false
    self.alert = false
    self.window = window.create(mainTerm, 1, 1, 30, 10)
    local procFunc,e
    if type(cmd) == "function" then

        procFunc = cmd
    elseif type(cmd) =="string" then
        procFunc,e = loadfile(cmd,"t",setmetatable({require=require},{__index=_G}))
        if procFunc == nil then
            error(e..": "..cmd)
        end
    else 
        error()
    end
    self.thread = pack.wolf:new(procFunc)
    function self.thread.onResume()
        term.redirect(self.window)
    end
    function self.thread.onEnd()
        self.window.setVisible(false)
    end
    p:add(self.thread)
end
function PW:draw(x)
    if self.alert then
        nft.draw(self.iconAlert,(x*4)+1,tbp,mainTerm)
        mainTerm.setCursorPos((x*4)+2,tbp-1)
        mainTerm.blit("\x13","e","7")
    elseif self.active then
        nft.draw(self.iconEnbl,(x*4)+1,tbp,mainTerm)
    else
        nft.draw(self.iconIdle,(x*4)+1,tbp,mainTerm)
    end
end
local programWindow = class(PW)
local test  = programWindow:new("test","/test.lua",builtinIcons.orangebox)
test.alert = true
local windows = {programWindow:new("test","/test.lua"),test}

local function drawTaskbar()
    mainTerm.setBackgroundColor(colors.gray)
    mainTerm.clear()
    for index, value in ipairs(windows) do
        value:draw(index-1)
    end
end
p:add(pack.wolf:new(drawTaskbar))
p:exec()
sleep(1)
mainTerm.setBackgroundColor(colors.gray)
mainTerm.clear()
drawTaskbar()
sleep(1)
term.setCursorPos(1,1)