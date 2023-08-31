term.setCursorPos(1,1)
term.setBackgroundColor(colors.red)
term.setTextColor(colors.white)
term.clear()
local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")

local decoder = dfpwm.make_decoder()
for chunk in io.lines("eas.dfpwm", 16 * 1024) do
    local buffer = decoder(chunk)

    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end
speaker.stop()

local message = [[The Jeff Team has released a emergency alert system test]]


local function centerText(text)
    local x,y = term.getSize()
    local x2,y2 = term.getCursorPos()
    term.setCursorPos(math.ceil((x / 2) - (text:len() / 2)), y2)
    write(text)
    end
    
centerText(message)
print()
print()

local url = "https://music.madefor.cc/tts?text=" .. textutils.urlEncode(message)
local response, err = http.get { url = url, binary = true }
if not response then error(err, 0) end
--decoder = dfpwm.make_decoder()
while true do
    local chunk = response.read(16 * 1024)
    if not chunk then break end

    local buffer = decoder(chunk)
    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end

speaker.stop()
