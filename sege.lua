local allwin = {}
local function swin(crx, cry, width, height, name, debug)
    for k,v in ipairs(allwin) do
        if v[4] == name then return nil, "Window with the name '" .. name .. "' already exists." end
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
        if debug == false then
            seclr(crx, cry, crx + winx - 1, cry + winy - 1)
        else
            term.clear()
        end
        
        crx = newCrx
        cry = newCry
        win.reposition(crx, cry)
        winmin.reposition(crx, cry+1)
        drawback(name)
    end

    table.insert(allwin,1,{ redrawWindow, crx, cry, name }) -- Register the window

    local function redrawAllWindows()
        if debug == false then
            seclr()
        end
        for k, v in ipairs(allwin) do
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
                    for k,v in ipairs(allwin) do
                        if v[4] == name then table.remove(allwin,k) end
                    end
                    f = fs.open("log","a")
                    f.write("window "..name.." closed\n")
                    f.close()
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

                    for k, v in ipairs(allwin) do
                        if v[4] == name then
                            allwin[name] = { redrawWindow, crx, cry, name }
                            break
                        end
                    end

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
local debu = true

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
