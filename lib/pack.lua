--[[
    Pack coroutine manager for WolfOS
]]--
local expect = require "cc.expect"
local class = require ".class"

local pack = class({constructor=function(self)
    self.wolves = {}
    self.running = false
end,add=function(self,w)
    table.insert(self.wolves,w)
end,exec=function(self)
    self.running = true
    local eventData = { n = 0 }
    while self.running do
        for index, w in ipairs(self.wolves) do
            w.onResume()
            local ok, param = coroutine.resume(w.r, table.unpack(eventData, 1, eventData.n))
            if not ok then
                error(param, 0)
            end
            if coroutine.status(w.r) == "dead" then
                table.remove(self.wolves,index)
            end
        end
        if #self.wolves == 0 then
            self.running = false
            break
        end
        eventData = table.pack(os.pullEventRaw())
        
    end
end})

local wolf = class({constructor=function(self,func)
    self.r = coroutine.create(func)
end,onResume=function(self)
    
end,onEnd=function(self)
    
end})
return {pack=pack,wolf=wolf}