print(" C[3_m  -  C[1;3_m")
for i = 30, 37, 1 do
    write(("\x1b[%dmE"):format(i))
end
write("-")
for i = 30, 37, 1 do
    write(("\x1b[1;%dmE"):format(i))
end
print("\x1b[0m")

for i = 30, 37, 1 do
    write(("\x1b[%dm%d"):format(i,i-30))
end
write("-")
for i = 90, 97, 1 do
    write(("\x1b[%dm%d"):format(i,i-90))
end
print("\x1b[0m")
print(" C[3_m  -  C[9_m ")
local pack = require ".lib.pack"
local p = pack.pack:new()
p:add(pack.wolf:new(function()
    for i = 1, 16, 1 do
        write(("%x"):format(i))
        sleep(0.1)
    end
    print("\x1b[0m1 done")
end))
p:add(pack.wolf:new(function()
    for i = 1, 16, 1 do
        write(("\x1b[%dm"):format((i%7)+30))
        sleep(0.1)
    end
    p:add(pack.wolf:new(function() 
        local event, character = os.pullEvent("char")
        print(character.." was pressed.") 
    end))
    print("2 done")
end))
p:exec()
print("done")