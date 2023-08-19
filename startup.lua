local boot = settings.get("wolfos.boot",{opt=false})
if boot.opt then
    local PrimeUI = require ".prime"
    local w,h = term.getSize()
    PrimeUI.clear()
    PrimeUI.label(term.current(), 3, 2, "WolfOS Boot")
    PrimeUI.horizontalLine(term.current(), 3, 3, #("WolfOS Boot") + 2)
    PrimeUI.borderBox(term.current(), 4, 6, w-7, h-7)
    local entries2 = {
        "WolfOS",
        "WolfOS-Kernel",
        "Option 3",
        "Option 4",
        "Option 5"
    }
    local entries2_descriptions = {
        "Boot WolfOS normaly",
        "Boot WolfOS to Kernel",
        "Vero sint asperiores sint ad et ducimus omnis blanditiis. Porro corporis veritatis quo consequatur voluptatum itaque cum. Consequatur nihil optio soluta beatae corporis distinctio sed dolores.",
        "Hic assumenda aliquid sunt delectus. Ratione consequatur impedit fuga dolorum a quidem et. Ea illum eius qui placeat exercitationem.",
        "Aspernatur in animi sint perspiciatis aliquam iste vero quas. Cumque beatae vel aut dolorum eos. Alias eligendi iure et et quia non autem possimus. Consectetur vel dicta ut. Officiis ex blanditiis non molestias. Non sed velit rerum aliquid doloribus."
    }
    local redraw = PrimeUI.textBox(term.current(), 4, h-4, w-7, 3, entries2_descriptions[1])
    PrimeUI.selectionBox(term.current(), 4, 6, w-7, h-10, entries2, "done", function(option) redraw(entries2_descriptions[option]) end)
    local _, _, selection = PrimeUI.run()
else
    shell.run("/sys/kernel.lua")
end

