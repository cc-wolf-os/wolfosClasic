--[[local pb = require "pixelbox_lite"
local b = pb.new(term)
local bgs = {colors.red,colors.orange,colors.yellow,colors.green,colors.blue}
local function draw()
    for index, value in ipairs(bgs) do
        local X = (index-1) *10
        for x = 1, 8, 1 do
            for y = 1, 8, 1 do
                b:set_pixel((x+1)+X,y+5,colors.gray)
            end
        end
        for x = 1, 6, 1 do
            for y = 1, 6, 1 do
                b:set_pixel((x+2)+X,y+6,value)
            end
        end
    end
    b:render()
    sleep(0.01)
end
draw()
term.blit(" --- ","f1111","f111f")
print()
term.blit(" --- ","f1111","f111f")
]]--
local nft = require "cc.image.nft"
term.clear()
local textImg = nft.parse(('\x1E1\x1F8\x97\x83\x1F1\x1E8\x94\n\x1F1\x1E8\x8A\x1E1\x1F0\xDF\x1F1\x1E8\x85'))
nft.draw(textImg, 1,1)
local noImg = nft.parse(('\x1EE\x1F0M\x1F8\x83\x1F0I\n\x1FE\x1E8\x8A\x1EE\x1F0\x13\x1FE\x1E8\x85'))
nft.draw(noImg, 1,4)
