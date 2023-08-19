local dim = {}
local class = require ".class"
local expect = require("cc.expect").expect
local pretty_print = require("cc.pretty").pretty_print

function table.merge(t1, t2)
    local t = {}
    for k,v in pairs(t1) do
        t[k] = v
    end
    for k,v in pairs(t2) do
        t[k] = v
    end 
  
    return t
 end

local file = class({constructor=function(self,F)
    expect(2,F,"string")
    local sz = fs.getSize(F)
    self.file_size = sz
    local rmn = sz
    local f = fs.open(F,"rb")
    local function read(i)
        rmn = rmn - (i or 1)
        return f.read(i)
    end
    if type(f) ~= "table" then
        printError("invalid file")
        textutils.pagedPrint(fs)
    elseif read(3) ~= "DIM" then
        printError("invalid file")
        f.seek("set",0)
        textutils.pagedPrint(f.readAll())
    else
        read()
        
        self.sectors = read()
        read()
        self.sectTbl = textutils.unserialise(f.readAll())

        

    end
    f.close()
end,save=function(self,to,s)
    expect(2,to,"string")
    expect(3,s,"number")
    if not fs.exists(to) then
        fs.makeDir(to)
    end
    local st = self.sectTbl[s]
    for index, value in ipairs(st.F) do
        if not fs.exists(fs.combine(to,value)) then
            fs.makeDir(fs.combine(to,value))
        end
    end
    for k, v in pairs(st.f) do
        local f = fs.open(fs.combine(to,k),"w")
        f.write(v[1])
        f.close()
    end
end})

local function ittrDir(dir,t,withn)
    withn = (withn or "")
    t = t or {F={},f={}}
    local content = fs.list(dir)
    for index, value in ipairs(content) do
        write(("%x,%s->"):format(index,dir..value))
        if fs.isDir(dir..value) then
            print("d")
            table.insert(t,withn..value)
            ittrDir(dir..value.."/",t,withn..value.."/")

        else
            print("f")
            local f=fs.open(dir..value,"rb")
            if f ~= nil then
                t.f[withn..value] = {f.readAll()}
                f.close()
            end
        end
    end
    return t
end
local create = class({constructor=function(self,F)
    expect(2,F,"string")
    self.F = F
    self.sectors = 1
    self.tbl = {{F={},f={}}}


end,add=function(self,dir)
    self.sectors =self.sectors +1
    table.insert(self.tbl,ittrDir(dir))
end,save=function(self)
    local f,e = fs.open(self.F,"wb")
    if f == nil then
        return nil,e
    end
    f.write(68)
    f.write(73)
    f.write(77)
    f.write(0)
    f.write(self.sectors)
    f.write(0)
    textutils.serialise(self.tbl):gsub(".", function(c)
        f.write(c:byte())
    end)
    f.close()
    return true

end})

return {file=file,create=create}