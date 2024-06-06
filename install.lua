local width, height = term.getSize()

local function update(text)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.setCursorPos(1, 9)
	term.clearLine()
	term.setCursorPos(math.floor(width/2 - string.len(text)/2), 9)
	write(text)
end

local function bar(ratio)
	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.lime)
	term.setCursorPos(1, 11)

	for i = 1, width do
		if (i/width < ratio) then
			write("]")
		else
			write(" ")
		end
	end
end

local function download(downloadPath, savePath)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.setCursorPos(1, 13)
	term.clearLine()
	term.setCursorPos(1, 14)
	term.clearLine()
	term.setCursorPos(1, 15)
	term.clearLine()
	term.setCursorPos(1, 16)
	term.clearLine()
	term.setCursorPos(1, 17)
	term.clearLine()
	term.setCursorPos(1, 13)

	print("Accessing https://raw.githubusercontent.com/yabastar0/seight/master/"..downloadPath)
	local rawData = http.get("https://raw.githubusercontent.com/yabastar0/seight/master/"..downloadPath)
	local data = rawData.readAll()
	local file = fs.open(savePath, "w")
	file.write(data)
	file.close()
end

function install()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.yellow)
	term.clear()

	local str = "Seight Installer"
	term.setCursorPos(math.floor(width/2 - #str / 2), 2)
	write(str)

	update("Installing...")
	bar(0)

	update("Downloading sege.lua...")
	download("sege.lua", "sege.lua")
	bar(0.2)

	update("Creating cfg folder...")
	fs.makeDir("cfg")
	bar(0.4)

	update("Downloading cfg...")
	download("cfg/cfg", "cfg/cfg")
	bar(0.5)

	update("Creating gfx folder...")
	fs.makeDir("gfx")
	bar(0.6)

    update("Downloading fex.nfp...")
	download("gfx/fex.nfp", "gfx/fex.nfp")
	bar(0.7) -- in the future, while downloading contents for a folder, keep the bar status the same

    update("Downloading gear.nfp...")
	download("gfx/gear.nfp", "gfx/gear.nfp")
	bar(0.8)

    update("Downloading nprov.nfp...")
	download("gfx/nprov.nfp", "gfx/nprov.nfp")
	bar(0.8)

    update("Downloading seight.nfp...")
	download("gfx/seight.nfp", "gfx/seight.nfp")
	bar(0.9)

    update("Downloading sysinfo.nfp...")
	download("gfx/sysinfo.nfp", "gfx/sysinfo.nfp")
	bar(0.9)

    update("Downloading term.nfp...")
	download("gfx/term.nfp", "gfx/term.nfp")
	bar(1)

	update("Installation finished!")

	sleep(1)

	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()

	term.setCursorPos(1, 1)
	write("Finished installation!\nPress any key to close...")

	os.pullEventRaw()

	term.clear()
	term.setCursorPos(1, 1)
end

install()
