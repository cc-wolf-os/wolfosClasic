--local pain = require("pixelterm").create(term.current())
--pain.setPixel(4,3,colors.lightBlue)
--pain.setPixel(3,4,colors.lightBlue)
--pain.setPixel(4,4,colors.lightBlue)
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
local function center(s,l)
    local pda = (l-#s)/2
    return ("%%-%ds"):format(pda):format("")..s..("%%-%ds"):format(pda):format("")
end
local pb = require "pixelbox_lite"

local b = pb.new(term)
local wh = 50
local cW= (wh/4)-4
local hwh = wh/2
local off = hwh+11
local offY = hwh -2
--local V = [[#####.......#####
--.....#.....#.....
--......#.x.#......
--.......# #.......
--........#........]]
local V = [[
.....#...........#.....
######.....#.....######
.....#...........#.....]]
local v = V:split("\n")
local coords = {}
for index, value in ipairs(v) do
    local vlue = string.format(("%%%ds"):format(off),value)
    v[index] = vlue
end
local anuc = {emrg=center("E",cW),auto=center("AUTOP",cW),flt=center("EEe",cW)}

for index, value in ipairs(v) do
    for i = 1, #value do
        local c = value:sub(i,i)
        if c == "#" then
            table.insert(coords,vector.new(index+offY,i,0))
        end
    end
end
local function coordsM(x,y)
    local v = vector.new(y,x,0)
    for index, value in ipairs(coords) do
        if v == value then
            return true
        end
    end
    return false
end
local function pxl(x,y,ptch)
    if y < ptch then
        if coordsM(x,y) then
            b:set_pixel(3+x,5+y,colors.red)
        else
            b:set_pixel(3+x,5+y,colors.lightBlue)
        end
        
    else
        if coordsM(x,y) then
            b:set_pixel(3+x,5+y,colors.orange)
        else
            b:set_pixel(3+x,5+y,colors.brown)
        end
    end
    
end
local function draw(i)
    
    --b:set_pixel(4,5,colors.lightBlue)
    --b:set_pixel(3,6,colors.lightBlue)
    --b:set_pixel(4,6,colors.lightBlue)
    for x = 0, wh, 1 do
        for y = 0, wh, 1 do
            pxl(x,y,i)
        end
    end
    b:render()
    term.setCursorPos(2,1)
    write(("|%s|%s|%s|"):format(anuc.flt,anuc.emrg,anuc.auto))
    sleep(0.1)
end

for i = 0, wh, 1 do
    draw(i)
end
term.setCursorPos(1,(wh/3)+5)
local pretty = require "cc.pretty"
pretty.pretty_print(v)
pretty.pretty_print(coords)