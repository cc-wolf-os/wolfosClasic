local drives = {}

local function disk_init_data(fptr, d)
	local fsize = 0
	if fptr ~= nil then
		fsize = fptr:seek("end")
		fptr:seek("set", 0)
	end

	print(string.format("fsize %02X == %d", d.id, fsize))
	d.inserted = true
	if fsize == 0 then
		d.inserted = false
		d.sector_size = 0
		d.sectors = 0
		d.heads = 0
		d.cylinders = 0
	elseif d.floppy then
		d.sector_size = 512
		if fsize == 2949120 then
			d.sectors = 36
			d.heads = 2
			d.cylinders = 80
		elseif fsize == 1761280 then
			d.sectors = 21
			d.heads = 2
			d.cylinders = 82
		elseif fsize == 1720320 then
			d.sectors = 21
			d.heads = 2
			d.cylinders = 80
		elseif fsize == 1474560 then
			d.sectors = 18
			d.heads = 2
			d.cylinders = 80
		elseif fsize == 1228800 then
			d.sectors = 15
			d.heads = 2
			d.cylinders = 80
		elseif fsize == 737280 then
			d.sectors = 9
			d.heads = 2
			d.cylinders = 80
		elseif fsize == (360*1024) then
			d.sectors = 9
			d.heads = 2
			d.cylinders = 40
		elseif fsize == (320*1024) then
			d.sectors = 8
			d.heads = 2
			d.cylinders = 40
		elseif fsize == (180*1024) then
			d.sectors = 9
			d.heads = 1
			d.cylinders = 40
		elseif fsize == (160*1024) then
			d.sectors = 8
			d.heads = 1
			d.cylinders = 40
		else
			error("unknown fsize: " .. fsize)
		end
	else
		d.sector_size = 512
		d.sectors = 63
		d.heads = 16
		d.cylinders = math.floor(fsize / (d.sector_size*d.sectors*d.heads))
		if d.cylinders <= 0 then
			error("unknown fsize: " .. fsize)
		end
	end
	print(string.format("disks: added %d x %d x %d x %d @ %02X", d.cylinders, d.heads, d.sectors, d.sector_size, d.id))

	-- configure table
	local tba = 0xF2000 + d.id*16
	if d.id == 0x80 then
		RAM:w16(0x0104, tba -band- 0xFFFF)
		RAM:w16(0x0106, 0xF000)
	elseif d.id == 0x81 then
		RAM:w16(0x0118, tba -band- 0xFFFF)
		RAM:w16(0x011A, 0xF000)
	elseif d.id == 0x00 then
		RAM:w16(0x0078, tba -band- 0xFFFF)
		RAM:w16(0x007A, 0xF000)
	end
	if d.floppy then
		RAM[tba] = 0xF0
		RAM[tba + 1] = 0x00
		RAM[tba + 2] = 0x00
		RAM[tba + 3] = math.ceil(d.sector_size / 128) - 1
		RAM[tba + 4] = d.sectors
		RAM[tba + 5] = 0
		RAM[tba + 6] = 0
		RAM[tba + 7] = 0
		RAM[tba + 8] = 0xF6
		RAM[tba + 9] = 0
		RAM[tba + 10] = 0
	else
		RAM:w16(tba, d.cylinders)
		RAM[tba + 2] = d.heads
		RAM:w16(tba + 3, 0)
		RAM:w16(tba + 5, 0)
		RAM[tba + 7] = 0
		RAM[tba + 8] = 0xC0
		if d.heads > 8 then
			RAM[tba + 8] = RAM[tba + 8] -bor- 0x08
		end
		RAM[tba + 9] = 0
		RAM[tba + 10] = 0
		RAM[tba + 11] = 0
		RAM:w16(tba + 12, 0)
		RAM[tba + 14] = d.sectors
	end
end

function disk_init(fn, id)
	local d = {}
	d.id = id
	local is_floppy = id < 0x80
	d.floppy = is_floppy

	if type(fn) == "function" then
		d.ptr = fn
	else
		local ptrmode = nil
		local f = nil
		d.ptr = function(a, mode)
			if ptrmode ~= mode then
				if f ~= nil then f:close() end
                f = io_seek.open(fn, mode)
				disk_init_data(f, a)
				f:seek("set", 0)
				ptrmode = mode
			end
			return f
		end
	end

	drives[id] = d
	if d.id >= 0x80 then
		RAM[0x475] = RAM[0x475] + 1
	end
end

function disk_has(id)
	return drives[id] ~= nil
end

local last_status = 0x00

local function ret_status(v)
	if v ~= nil then
		print("disks: setting status to " .. v)
		last_status = v -band- 0xFF
	end
	CPU["regs"][1] = (CPU["regs"][1] -band- 0xFF) -bor- (last_status -blshift- 8)
	cpu_write_flag(0, last_status ~= 0)
end