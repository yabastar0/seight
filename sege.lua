local x,y = term.getSize()
if x < 51 or y < 19 then
    print("Your terminal must be atleast 51 x 19. Your terminal is currently "..x.." x "..y)
else
  
-- betterblittle by Xella

local floor = math.floor
local concat = table.concat

local colorChar = {}
for i = 1, 16 do
	colorChar[2 ^ (i - 1)] = ("0123456789abcdef"):sub(i, i)
end

local function getColorsFromPixelGroup(p1, p2, p3, p4, p5, p6)
	local freq = {}
	freq[p1] = 1
	freq[p2] = (freq[p2] or 0) + 1
	freq[p3] = (freq[p3] or 0) + 1
	freq[p4] = (freq[p4] or 0) + 1
	freq[p5] = (freq[p5] or 0) + 1
	freq[p6] = (freq[p6] or 0) + 1

	local highest = p1
	local highestCount = 0
	local secondHighest = p1
	local secondHighestCount = 0
	for color, count in pairs(freq) do
		if count > secondHighestCount then
			if count > highestCount then
				secondHighest = highest
				secondHighestCount = highestCount
				highest = color
				highestCount = count
			else
				secondHighest = color
				secondHighestCount = count
			end
		end
	end

	return highest, secondHighest
end

local relationsBlittle = {[0] = {8, 4, 3, 6, 5}, {4, 14, 8, 7}, {6, 10, 8, 7}, {9, 11, 8, 0}, {1, 14, 8, 0}, {13, 12, 8, 0}, {2, 10, 8, 0}, {15, 8, 10, 11, 12, 14}, {0, 7, 1, 9, 2, 13}, {3, 11, 8, 7}, {2, 6, 7, 15}, {9, 3, 7, 15}, {13, 5, 7, 15}, {5, 12, 8, 7}, {1, 4, 7, 15}, {7, 10, 11, 12, 14}}
local relations = {}
for i = 0, 15 do
	local r = relationsBlittle[i]
	for i = 1, #r do
		r[i] = math.pow(2, r[i])
	end
	relations[math.pow(2, i)] = r
end
local function colorCloser(target, c1, c2)
	local r = relations[target]
	for i = 1, #r do
		if r[i] == c1 then return true
		elseif r[i] == c2 then return false end
	end

	return false
end

local char = string.char
local allChars = {}
for i = 128, 128+31 do
	allChars[i] = char(i)
end
local bxor = bit.bxor
local function getCharFomPixelGroup(c1, c2, p1, p2, p3, p4, p5, p6)
	local cc = colorCloser
	local charNr = 128
	if p1 == c1 or p1 ~= c2 and cc(p1, c1, c2) then charNr = charNr + 1 end
	if p2 == c1 or p2 ~= c2 and cc(p2, c1, c2) then charNr = charNr + 2 end
	if p3 == c1 or p3 ~= c2 and cc(p3, c1, c2) then charNr = charNr + 4 end
	if p4 == c1 or p4 ~= c2 and cc(p4, c1, c2) then charNr = charNr + 8 end
	if p5 == c1 or p5 ~= c2 and cc(p5, c1, c2) then charNr = charNr + 16 end
	if p6 == c1 or p6 ~= c2 and cc(p6, c1, c2) then
		return allChars[bxor(31, charNr)], true
	end
	return allChars[charNr], false
end

local function drawBuffer(buffer, win)
	local height = #buffer
	local width = #buffer[1]

	local maxX = floor(width / 2)
	local setCursorPos = win.setCursorPos
	local blit = win.blit
	local colorChar = colorChar
	for y = 1, floor(height / 3) do
		local oy = (y-1) * 3 + 1

		local r1 = buffer[oy] -- first row from buffer for this row of characters
		local r2 = buffer[oy+1] -- second row from buffer for this row of characters
		local r3 = buffer[oy+2] -- third row from buffer for this row of characters

		local blitC1 = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
		local blitC2 = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
		local blitChar = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
		for x = 1, maxX do
			local ox = (x-1) * 2 + 1

			local p1 = r1[ox]
			local p2 = r1[ox+1]
			local p3 = r2[ox]
			local p4 = r2[ox+1]
			local p5 = r3[ox]
			local p6 = r3[ox+1]
			if p1 == p2 and p2 == p3 and p3 == p4 and p4 == p5 and p5 == p6 then
				local c = colorChar[p1]
				blitC1[x] = c
				blitC2[x] = c
				blitChar[x] = "\x80"
			else
				local c1, c2 = getColorsFromPixelGroup(p1, p2, p3, p4, p5, p6)
				local char, swapColors = getCharFomPixelGroup(c1, c2, p1, p2, p3, p4, p5, p6)
				if swapColors then
					local cC2 = colorChar[c2]
					local cC1 = colorChar[c1]
					blitC1[x] = cC2
					blitC2[x] = cC1
				else
					local cC2 = colorChar[c2]
					local cC1 = colorChar[c1]
					blitC1[x] = cC1
					blitC2[x] = cC2
				end
				blitChar[x] = char
			end
		end
		local con = concat
		local c1 = con(blitChar)
		local c2 = con(blitC1)
		local c3 = con(blitC2)
		setCursorPos(1, y)
		blit(c1, c2, c3)
	end
end

-- PrimeUI by JackMacWindows
-- Public domain/CC0

local expect = require "cc.expect".expect

-- Initialization code
local PrimeUI = {}
do
    local coros = {}
    local restoreCursor

    --- Adds a task to run in the main loop.
    ---@param func function The function to run, usually an `os.pullEvent` loop
    function PrimeUI.addTask(func)
        expect(1, func, "function")
        local t = {coro = coroutine.create(func)}
        coros[#coros+1] = t
        _, t.filter = coroutine.resume(t.coro)
    end

    --- Sends the provided arguments to the run loop, where they will be returned.
    ---@param ... any The parameters to send
    function PrimeUI.resolve(...)
        coroutine.yield(coros, ...)
    end

    --- Clears the screen and resets all components. Do not use any previously
    --- created components after calling this function.
    function PrimeUI.clear()
        -- Reset the screen.
        term.setCursorPos(1, 1)
        term.setCursorBlink(false)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        -- Reset the task list and cursor restore function.
        coros = {}
        restoreCursor = nil
    end

    --- Sets or clears the window that holds where the cursor should be.
    ---@param win window|nil The window to set as the active window
    function PrimeUI.setCursorWindow(win)
        expect(1, win, "table", "nil")
        restoreCursor = win and win.restoreCursor
    end

    --- Gets the absolute position of a coordinate relative to a window.
    ---@param win window The window to check
    ---@param x number The relative X position of the point
    ---@param y number The relative Y position of the point
    ---@return number x The absolute X position of the window
    ---@return number y The absolute Y position of the window
    function PrimeUI.getWindowPos(win, x, y)
        if win == term then return x, y end
        while win ~= term.native() and win ~= term.current() do
            if not win.getPosition then return x, y end
            local wx, wy = win.getPosition()
            x, y = x + wx - 1, y + wy - 1
            _, win = debug.getupvalue(select(2, debug.getupvalue(win.isColor, 1)), 1) -- gets the parent window through an upvalue
        end
        return x, y
    end

    --- Runs the main loop, returning information on an action.
    ---@return any ... The result of the coroutine that exited
    function PrimeUI.run()
        while true do
            -- Restore the cursor and wait for the next event.
            if restoreCursor then restoreCursor() end
            local ev = table.pack(os.pullEvent())
            -- Run all coroutines.
            for _, v in ipairs(coros) do
                if v.filter == nil or v.filter == ev[1] then
                    -- Resume the coroutine, passing the current event.
                    local res = table.pack(coroutine.resume(v.coro, table.unpack(ev, 1, ev.n)))
                    -- If the call failed, bail out. Coroutines should never exit.
                    if not res[1] then error(res[2], 2) end
                    -- If the coroutine resolved, return its values.
                    if res[2] == coros then return table.unpack(res, 3, res.n) end
                    -- Set the next event filter.
                    v.filter = res[2]
                end
            end
        end
    end
end

local f = fs.open("cfg/cfg", "r")
local loc = textutils.unserialise(f.readAll())
f.close()

function trunc(str, size)
    local maxSize = size - 1
    if #str > maxSize then
        return string.sub(str, 1, maxSize) .. string.char(187)
    else
        return str .. string.rep(" ", size - #str)
    end
end

local function menu(opts)
    local x2, y2 = term.getCursorPos()
    local text = term.getTextColor()
    local bg = term.getBackgroundColor()
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.white)
    term.setCursorPos(1,1)

    local dbar = string.char(0xA6)
    term.write("sege ")

    for k,v in ipairs(opts) do
        term.write(" "..dbar.." "..v.." ")
    end
    
    term.setTextColor(text)
    term.setBackgroundColor(bg)
    term.setCursorPos(x2, y2)
end

local function redrawIcons()
    local termWidth, termHeight = term.getSize()
    local text = term.getTextColor()
    local bg = term.getBackgroundColor()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    local startX = 3
    local startY = 3
    local currentX = startX
    local currentY = startY

    local imageWidth = 5
    local imageHeight = 3
    local labelY = 6

    for k, v in ipairs(loc) do
        if currentX + imageWidth > termWidth then
            currentX = startX
            currentY = currentY + imageHeight + 3 -- Adjust this if you want more spacing
        end

        local pinestore_logo = paintutils.loadImage(v[1])
        if pinestore_logo == nil then
            pinestore_logo = paintutils.loadImage("gfx/nprov.nfp")
        end
        local logo_window = window.create(term.current(), currentX, currentY, imageWidth, imageHeight)
        drawBuffer(pinestore_logo, logo_window)
        
        local x2, y2 = term.getCursorPos()
        term.setCursorPos(currentX-1, currentY + imageHeight + 1)
        term.write(trunc(v[2], 7))
        term.setCursorPos(x2, y2)
        
        currentX = currentX + imageWidth + 4 -- Adjust this if you want more spacing
    end
    term.setTextColor(text)
    term.setBackgroundColor(bg)
end

local function seclr(xs,ys,xw,yw)
    local x2, y2 = term.getCursorPos()
    local text = term.getTextColor()
    local bg = term.getBackgroundColor()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    local xw = xw or x
    local yw = yw or y
    local xs = xs or 1
    local ys = ys or 1
    for i = xs, xw do
        for i2 = ys, yw do
            term.setCursorPos(i, i2)
            term.write(string.char(0x7F))
        end
    end

    -- the logo is a bit big, nothing is wrong though 
    --[[
    pinestore_logo = paintutils.loadImage("seight.nfp")
    local logo_window = window.create(term.current(), 1, y-2, 16, 3)
    drawBuffer(pinestore_logo, logo_window)
    ]]

    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.white)
    term.setCursorPos(1,1)

    menu({"about","view"})

    redrawIcons()
    term.setTextColor(text)
    term.setBackgroundColor(bg)
    term.setCursorPos(x2, y2)
end

seclr()

local allwin = {}
local function swin(crx, cry, width, height, name, debug)
    -- Ensure unique names in the allwin table
    if allwin[name] then
        return nil, "Window with the name '" .. name .. "' already exists."
    end

    local win = window.create(term.current(), crx, cry, width, height)
    local winmin = window.create(term.current(), crx, cry + 1, width, height - 1)

    win.setBackgroundColour(colours.white)
    win.setTextColour(colours.black)
    win.clear()

    winmin.setBackgroundColour(colours.white)
    winmin.setTextColour(colours.black)
    winmin.clear()

    local function drawback(name)
        local x, y = win.getSize()
        win.setCursorPos(1, 1)
        win.setTextColour(colours.black)
        win.setBackgroundColour(colours.white)
        for i = 1, x do
            win.write("=")
        end

        local newxpos = math.floor((x - #name) / 2) + 1

        if newxpos > 1 then
            win.setCursorPos(newxpos, 1)
            win.write(name)
        end

        win.setCursorPos(x - 2, 1)
        win.write(string.char(0x8C))

        win.setTextColour(colours.white)
        win.setBackgroundColour(colours.black)

        win.setCursorPos(x - 1, 1)
        win.write(string.char(0x84))
        win.setCursorPos(x - 3, 1)
        win.write(string.char(0x88))
    end

    local function redrawWindow(newCrx, newCry)
        local winx, winy = win.getSize()
        seclr(crx, cry, crx + winx - 1, cry + winy - 1)
        
        crx = newCrx
        cry = newCry
        win.reposition(crx, cry)
        winmin.reposition(crx, cry+1)
        drawback(name)
    end

    allwin[name] = { redrawWindow, crx, cry } -- Register the window

    local function redrawAllWindows()
        if debug == false then
            seclr()
        end
        for k, v in pairs(allwin) do
            local redr = v[1]
            redr(v[2], v[3])
        end
    end

    local function listen()
        local dragging = false
        local dragOffsetX, dragOffsetY = 0, 0
        local accumulatedCrx, accumulatedCry = crx, cry
    
        while true do
            local eventData = { os.pullEvent() }
            local event = eventData[1]
            local button = eventData[2]
            local x2 = eventData[3]
            local y2 = eventData[4]
    
            if event == "mouse_click" then
                if button == 1 and y2 == cry and (x2 >= crx + width - 4 and x2 <= crx + width - 1) then
                    term.clear()
                    if debug == false then
                        seclr()
                        redrawIcons()
                    end
                    allwin[name] = nil -- Remove the window
                    redrawAllWindows()
                    break
                elseif button == 1 and y2 == cry and (x2 >= crx and x2 < crx + width - 4) then
                    dragging = true
                    dragOffsetX = x2 - crx
                    dragOffsetY = y2 - cry
                end
            elseif event == "mouse_up" then
                if dragging then
                    dragging = false
                    local newCrx = math.max(0, math.min(accumulatedCrx, term.getSize() - width))
                    local newCry = math.max(0, math.min(accumulatedCry, term.getSize() - height))
    
                    allwin[name] = { redrawWindow, newCrx, newCry }
                    redrawAllWindows()
                end
            elseif event == "mouse_drag" and dragging then
                accumulatedCrx = x2 - dragOffsetX
                accumulatedCry = y2 - dragOffsetY
            end
        end
    end

    drawback(name)
    return winmin, listen
end

local crx = 1
local cry = 1
local width = 40
local height = 25
local name = "SEGE v1.0"
local debu = false

local mywin, listener = swin(crx, cry, width, height, name, debu)

local function main()
    mywin.write("hello, world!")

    local mywin2, listener2 = swin(crx + 8, cry + 8, width, height, name .. "2", debu)

    local function main2()
        mywin2.write("hello, world! 2")
    end
    parallel.waitForAll(main2, listener2)
end

parallel.waitForAll(main, listener)

term.setCursorPos(1, 1)
end -- ends the terminal check "else"
