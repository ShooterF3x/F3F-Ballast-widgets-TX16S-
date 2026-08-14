-- /WIDGETS/ballast/main.lua
-- EdgeTX Widget (main screen, color touch) - F3F Ballast Management (Corrigé)

local name = "BALLAST"
local options = {}

------------------------------------------------------------------
-- DATA / MODELS
------------------------------------------------------------------
local defaultModels = {
    { name="FREESTYLER", emptyW=2100, emptyCG=100, targetCG=100, area=60, vMin=3.0, wMin=2100, vMax=15.0, wMax=3300, chambers={{n="JOINER", d=100, m=200, max=4, qty=0}, {n="WINGS", d=140, m=150, max=6, qty=0}, {n="FUSELAGE", d=0, m=100, max=2, qty=0}} },
    { name="JAZZ",       emptyW=2350, emptyCG=98,  targetCG=98,  area=58, vMin=3.0, wMin=2350, vMax=15.0, wMax=3500, chambers={{n="SPARS", d=98, m=180, max=4, qty=0}, {n="TIPS", d=158, m=140, max=4, qty=0}} }
}

local filename = "/WIDGETS/ballast/ballast_cfg.txt"
local charset = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_*"

local function getCharIdx(c)
    if not c or c == "" then return 1 end
    local idx = string.find(charset, c, 1, true)
    return idx or 1
end

local function setCharAt(str, pos, char)
    local padded = string.format("%-10s", str)
    return string.sub(padded, 1, pos-1) .. char .. string.sub(padded, pos+1)
end

local function saveData(w)
    local f = io.open(filename, "w")
    if f then
        io.write(f, "mIdx=" .. tostring(w.mIdx) .. "\n")
        io.write(f, "wind=" .. tostring(w.wind) .. "\n")
        io.write(f, "num_models=" .. tostring(#w.models) .. "\n")
        for i, m in ipairs(w.models) do
            io.write(f, "m_"..i.."_name=" .. tostring(m.name) .. "\n")
            io.write(f, "m_"..i.."_area=" .. tostring(m.area) .. "\n")
            io.write(f, "m_"..i.."_tCG=" .. tostring(m.targetCG) .. "\n")
            io.write(f, "m_"..i.."_eW=" .. tostring(m.emptyW) .. "\n")
            io.write(f, "m_"..i.."_eCG=" .. tostring(m.emptyCG) .. "\n")
            io.write(f, "m_"..i.."_vMin=" .. tostring(m.vMin or 3.0) .. "\n")
            io.write(f, "m_"..i.."_wMin=" .. tostring(m.wMin or m.emptyW) .. "\n")
            io.write(f, "m_"..i.."_vMax=" .. tostring(m.vMax or 15.0) .. "\n")
            io.write(f, "m_"..i.."_wMax=" .. tostring(m.wMax or (m.emptyW + 1000)) .. "\n")
            io.write(f, "m_"..i.."_nCh=" .. tostring(#m.chambers) .. "\n")
            for j, c in ipairs(m.chambers) do
                io.write(f, "m_"..i.."_c_"..j.."_n=" .. tostring(c.n) .. "\n")
                io.write(f, "m_"..i.."_c_"..j.."_max=" .. tostring(c.max) .. "\n")
                io.write(f, "m_"..i.."_c_"..j.."_m=" .. tostring(c.m) .. "\n")
                io.write(f, "m_"..i.."_c_"..j.."_d=" .. tostring(c.d) .. "\n")
            end
        end
        io.close(f)
    end
end

local function loadData(w)
    local f = io.open(filename, "r")
    if f then
        local content = io.read(f, 4096)
        io.close(f)
        if content and content ~= "" then
            local val = string.match(content, "mIdx=(%d+)")
            if val then w.mIdx = tonumber(val) end
            val = string.match(content, "wind=([%d%.]+)")
            if val then w.wind = tonumber(val) end
            local numModels = tonumber(string.match(content, "num_models=(%d+)"))
            if numModels and numModels > 0 then
                local parsed = {}
                for i = 1, numModels do
                    local mName = string.match(content, "m_"..i.."_name=([^\n\r]+)")
                    if mName then
                        mName = string.gsub(mName, "\r", "")
                        local mArea = tonumber(string.match(content, "m_"..i.."_area=([%d%.]+)")) or 60
                        local mtCG = tonumber(string.match(content, "m_"..i.."_tCG=([%d%.]+)")) or 100
                        local meW = tonumber(string.match(content, "m_"..i.."_eW=(%d+)")) or 2000
                        local meCG = tonumber(string.match(content, "m_"..i.."_eCG=([%d%.]+)")) or 100
                        local mvMin = tonumber(string.match(content, "m_"..i.."_vMin=([%d%.]+)")) or 3.0
                        local mwMin = tonumber(string.match(content, "m_"..i.."_wMin=(%d+)")) or meW
                        local mvMax = tonumber(string.match(content, "m_"..i.."_vMax=([%d%.]+)")) or 15.0
                        local mwMax = tonumber(string.match(content, "m_"..i.."_wMax=(%d+)")) or (meW + 1000)
                        local mnCh = tonumber(string.match(content, "m_"..i.."_nCh=(%d+)")) or 0
                        local chs = {}
                        for j = 1, mnCh do
                            local cn = string.match(content, "m_"..i.."_c_"..j.."_n=([^\n\r]+)") or ("CHMBR"..j)
                            cn = string.gsub(cn, "\r", "")
                            local cmax = tonumber(string.match(content, "m_"..i.."_c_"..j.."_max=(%d+)")) or 4
                            local cm = tonumber(string.match(content, "m_"..i.."_c_"..j.."_m=(%d+)")) or 100
                            local cd = tonumber(string.match(content, "m_"..i.."_c_"..j.."_d=(-?%d+)")) or 0
                            table.insert(chs, {n=cn, max=cmax, m=cm, d=cd, qty=0})
                        end
                        table.insert(parsed, {name=mName, area=mArea, targetCG=mtCG, emptyW=meW, emptyCG=meCG, vMin=mvMin, wMin=mwMin, vMax=mvMax, wMax=mwMax, chambers=chs})
                    end
                end
                if #parsed > 0 then w.models = parsed end
                if w.mIdx > #w.models then w.mIdx = 1 end
            end
        end
    end
end

------------------------------------------------------------------
-- LINEAR CURVE CALCULATION
------------------------------------------------------------------
local function calc(w)
    local g = w.models[w.mIdx]
    if not g then return end
    
    g.vMin = g.vMin or 3.0
    g.wMin = g.wMin or g.emptyW
    g.vMax = g.vMax or 15.0
    g.wMax = g.wMax or (g.emptyW + 1000)

    if w.wind <= g.vMin then
        w.targetW = g.wMin
    elseif w.wind >= g.vMax then
        w.targetW = g.wMax
    else
        local slope = (g.wMax - g.wMin) / (g.vMax - g.vMin)
        w.targetW = g.wMin + slope * (w.wind - g.vMin)
    end
    if w.targetW < g.emptyW then w.targetW = g.emptyW end

    w.maxModelW = g.emptyW
    for _, c in ipairs(g.chambers) do w.maxModelW = w.maxModelW + (c.max * c.m) end

    w.currentW = g.emptyW
    for _, c in ipairs(g.chambers) do c.qty = 0 end
    
    local function computeState(chambers, currentW)
        local mom = g.emptyW * g.emptyCG
        for _, c in ipairs(chambers) do
            mom = mom + (c.qty * c.m * c.d)
        end
        return mom / currentW
    end

    w.currentCG = computeState(g.chambers, w.currentW)

    while w.currentW < w.targetW do
        local bestChamber = -1
        local minCGDiff = 999999
        local bestNewCG = w.currentCG

        for i, c in ipairs(g.chambers) do
            if c.qty < c.max then
                c.qty = c.qty + 1
                local simW = w.currentW + c.m
                local simCG = computeState(g.chambers, simW)
                local diff = math.abs(simCG - g.targetCG)

                if diff < minCGDiff then
                    minCGDiff = diff
                    bestChamber = i
                    bestNewCG = simCG
                end
                c.qty = c.qty - 1
            end
        end

        if bestChamber ~= -1 then
            g.chambers[bestChamber].qty = g.chambers[bestChamber].qty + 1
            w.currentW = w.currentW + g.chambers[bestChamber].m
            w.currentCG = bestNewCG
        else
            break
        end
    end
end

------------------------------------------------------------------
-- UNIVERSAL WHEEL / BUTTONS MANAGEMENT
------------------------------------------------------------------
local function getStep(event)
    if event == EVT_ROT_RIGHT or event == EVT_PLUS_FIRST or event == EVT_PLUS_BREAK then return 1 end
    if event == EVT_ROT_LEFT or event == EVT_MINUS_FIRST or event == EVT_MINUS_BREAK then return -1 end
    return 0
end

------------------------------------------------------------------
-- WIDGET CYCLE
------------------------------------------------------------------
local function create(zone, opts)
    local w = {
        zone = zone, options = opts,
        models = defaultModels,
        mIdx = 1, wind = 6.5, page = 1, chIdx = 1, editParam = 1,
        configParam = 1, actionIdx = 1, dashParam = 1,
        currentW = 0, currentCG = 0, targetW = 0, maxModelW = 0,
        editMode = 0, strCursor = 1
    }
    loadData(w)
    calc(w)
    return w
end

local function update(w, opts) w.options = opts end
local function background(w) end

local function drawHeader(w, ww, title)
    lcd.drawFilledRectangle(0, 0, ww, 22, BLUE)
    lcd.drawText(8, 3, title, SMLSIZE + WHITE)
end

local function hit(t, x, y, ww, hh)
    if not t then return false end
    return t.x >= x and t.x <= x + ww and t.y >= y and t.y <= y + hh
end

local function drawTabs(w, ww, hh, touchState)
    local labels = {"FLIGHT", "CONFIG", "CHAMBERS", "MANAGE"}
    local tw = ww / 4
    for i = 1, 4 do
        local x = (i-1) * tw
        lcd.drawFilledRectangle(x, hh - 22, tw - 1, 22, w.page == i and RED or DARKGREY)
        lcd.drawText(x + tw/2, hh - 20, labels[i], CENTER + SMLSIZE + WHITE)
        if touchState and touchState.tapCount and touchState.tapCount > 0 and hit(touchState, x, hh-22, tw-1, 22) then
            w.page = i; w.editMode = 0
        end
    end
end

------------------------------------------------------------------
-- HELPER: DRAWING HIGHLIGHTED VALUES
------------------------------------------------------------------
local function drawEditableValue(x, y, label, valueTxt, isSel, isEdit)
    lcd.drawText(x, y, label, SMLSIZE + BLACK)
    
    local lx = lcd.getTextWidth and lcd.getTextWidth(label, SMLSIZE) or (string.len(label) * 6)
    local vx = x + lx

    if isEdit then
        local tw = lcd.getTextWidth and lcd.getTextWidth(valueTxt, SMLSIZE) or (string.len(valueTxt) * 6)
        local th = 16 
        
        lcd.drawFilledRectangle(vx - 2, y - 2, tw + 4, th + 4, RED)
        lcd.drawText(vx, y, valueTxt, SMLSIZE + WHITE)
    else
        lcd.drawText(vx, y, valueTxt, SMLSIZE + (isSel and RED or BLACK))
    end
end

------------------------------------------------------------------
-- PAGE 1: DASHBOARD
------------------------------------------------------------------
local function pagedashboard(w, ww, hh, event, touchState)
    local g = w.models[w.mIdx]
    
    local step = getStep(event)
    if step ~= 0 then
        if w.editMode == 0 then
            w.dashParam = (w.dashParam == 1) and 2 or 1
        else
            if w.dashParam == 1 then
                w.wind = math.max(0.0, math.min(30.0, w.wind + step * 0.5))
                calc(w); saveData(w)
            elseif w.dashParam == 2 then
                w.mIdx = w.mIdx + step
                if w.mIdx > #w.models then w.mIdx = 1 elseif w.mIdx < 1 then w.mIdx = #w.models end
                calc(w); saveData(w)
            end
        end
    elseif event == EVT_ENTER_BREAK then
        w.editMode = 1 - w.editMode
    end

    local isSelWind = (w.dashParam == 1)
    local isEditWind = (isSelWind and w.editMode == 1)
    drawEditableValue(ww/2 - 60, 34, "WIND: ", string.format("%.1f", w.wind) .. " m/s", isSelWind, isEditWind)
    lcd.drawText(ww/2, 62, "TARGET: " .. math.floor(w.targetW) .. " g", CENTER + SMLSIZE + BLACK)

    local isSelMod = (w.dashParam == 2)
    local isEditMod = (isSelMod and w.editMode == 1)
    local rModel = {x=0, y=84, w=ww, h=22}
    lcd.drawFilledRectangle(rModel.x, rModel.y, rModel.w, rModel.h, isEditMod and RED or DARKGREY)
    lcd.drawText(ww/2, rModel.y + 4, "MODEL: " .. g.name, CENTER + SMLSIZE + ((isSelMod and not isEditMod) and GREEN or WHITE))

    local barX, barY, barW, barH = 8, 114, ww - 16, 14
    lcd.drawRectangle(barX, barY, barW, barH, BLACK)
    
    local span = w.maxModelW - g.emptyW
    local ratio = 0
    if span > 0 then
        ratio = math.max(0, math.min(1.0, (w.currentW - g.emptyW) / span))
    end
    local fillW = math.floor((barW - 4) * ratio)
    if fillW > 0 then 
        lcd.drawFilledRectangle(barX + 2, barY + 2, fillW, barH - 4, GREEN) 
    end
    lcd.drawText(ww/2, barY + barH + 4, w.currentW .. "g / " .. w.maxModelW .. "g max", CENTER + SMLSIZE + BLACK)

    lcd.drawText(8, 150, "WEIGHT: " .. w.currentW .. " g", SMLSIZE + BLACK)
    lcd.drawText(8, 168, "CG: " .. string.format("%.1f", w.currentCG) .. " / " .. g.targetCG .. " mm", SMLSIZE + BLACK)
    local cgOk = math.abs(w.currentCG - g.targetCG) <= 0.5
    lcd.drawFilledRectangle(ww - 30, 150, 20, 30, cgOk and GREEN or RED)

    local y = 188
    for i, c in ipairs(g.chambers) do
        if y <= hh - 26 then
            lcd.drawText(8, y, string.format("%d. %-8s %d/%d  (+%dg)", i, c.n, c.qty, c.max, c.qty * c.m), SMLSIZE + BLACK)
            y = y + 14
        end
    end
end

------------------------------------------------------------------
-- PAGE 2: GLOBAL CONFIG & BALLAST CURVE
------------------------------------------------------------------
local function pageconfig(w, ww, hh, event, touchState)
    local g = w.models[w.mIdx]
    g.vMin = g.vMin or 3.0
    g.wMin = g.wMin or g.emptyW
    g.vMax = g.vMax or 15.0
    g.wMax = g.wMax or (g.emptyW + 1000)

    local maxParams = 8

    local step = getStep(event)
    if step ~= 0 then
        if w.editMode == 0 then
            w.configParam = w.configParam + step
            if w.configParam > maxParams then w.configParam = 1 elseif w.configParam < 1 then w.configParam = maxParams end
        else
            if w.configParam == 1 then
                local idx = getCharIdx(string.sub(g.name, w.strCursor, w.strCursor)) + step
                if idx > #charset then idx = 1 elseif idx < 1 then idx = #charset end
                g.name = setCharAt(g.name, w.strCursor, string.sub(charset, idx, idx))
            elseif w.configParam == 2 then g.targetCG = math.max(0, g.targetCG + step * 0.1)
            elseif w.configParam == 3 then g.emptyW = math.max(0, g.emptyW + step * 10)
            elseif w.configParam == 4 then g.emptyCG = math.max(0, g.emptyCG + step * 0.5)
            elseif w.configParam == 5 then g.vMin = math.max(0.0, g.vMin + step * 0.5)
            elseif w.configParam == 6 then g.wMin = math.max(0, g.wMin + step * 20)
            elseif w.configParam == 7 then g.vMax = math.max(0.0, g.vMax + step * 0.5)
            elseif w.configParam == 8 then g.wMax = math.max(0, g.wMax + step * 20)
            end
            calc(w); saveData(w)
        end
    elseif event == EVT_ENTER_BREAK then
        if w.configParam == 1 then
            if w.editMode == 0 then w.editMode = 1; w.strCursor = 1; g.name = string.format("%-10s", g.name)
            else
                w.strCursor = w.strCursor + 1
                if w.strCursor > 10 then
                    w.editMode = 0; w.strCursor = 1
                    g.name = string.match(g.name, "^%s*(.-)%s*$") or "MODEL"
                    saveData(w)
                end
            end
        else
            w.editMode = 1 - w.editMode
        end
    end

    local rows = {
        {label = "Name", get = function() return (w.configParam==1 and w.editMode==1) and (string.sub(g.name, 1, w.strCursor-1) .. "[" .. string.sub(g.name, w.strCursor, w.strCursor) .. "]" .. string.sub(g.name, w.strCursor+1)) or g.name end},
        {label = "Target CG (mm)", get = function() return string.format("%.1f", g.targetCG) end},
        {label = "Empty Wght (g)", get = function() return tostring(g.emptyW) end},
        {label = "Empty CG (mm)", get = function() return string.format("%.1f", g.emptyCG) end},
        {label = "Min Wind Pt (m/s)", get = function() return string.format("%.1f", g.vMin) end},
        {label = "Min Wght Pt (g)", get = function() return tostring(g.wMin) end},
        {label = "Max Wind Pt (m/s)", get = function() return string.format("%.1f", g.vMax) end},
        {label = "Max Wght Pt (g)", get = function() return tostring(g.wMax) end},
    }

    for i, row in ipairs(rows) do
        local y = 26 + (i-1) * 20
        local isSel = (w.configParam == i)
        local isEdit = (isSel and w.editMode == 1)

        if i == 1 then
            lcd.drawText(8, y, i .. ". " .. row.label .. ": " .. row.get(), SMLSIZE + (isSel and RED or BLACK))
        else
            drawEditableValue(8, y, i .. ". " .. row.label .. ": ", row.get(), isSel, isEdit)
        end
    end
end

------------------------------------------------------------------
-- PAGE 3: CHAMBERS
------------------------------------------------------------------
local function pagesoutes(w, ww, hh, event, touchState)
    local g = w.models[w.mIdx]
    if w.chIdx > #g.chambers then w.chIdx = #g.chambers end
    if w.chIdx < 1 then w.chIdx = 1 end
    local c = g.chambers[w.chIdx]

    local maxParams = 6

    local step = getStep(event)
    if step ~= 0 then
        if w.editMode == 0 then
            w.editParam = w.editParam + step
            if w.editParam > maxParams then w.editParam = 1 elseif w.editParam < 1 then w.editParam = maxParams end
        else
            if w.editParam == 1 then
                w.chIdx = w.chIdx + step
                if w.chIdx > #g.chambers then w.chIdx = 1 elseif w.chIdx < 1 then w.chIdx = #g.chambers end
            elseif w.editParam == 2 then c.max = math.max(0, c.max + step)
            elseif w.editParam == 3 then c.m = math.max(0, c.m + step * 5)
            elseif w.editParam == 4 then c.d = c.d + step * 5 
            elseif w.editParam == 5 or w.editParam == 6 then
                w.editParam = w.editParam + step
                if w.editParam > maxParams then w.editParam = 1 elseif w.editParam < 1 then w.editParam = maxParams end
            end
            calc(w); saveData(w)
        end
    elseif event == EVT_ENTER_BREAK then
        if w.editParam == 5 then
            table.insert(g.chambers, {n="CHMBR" .. (#g.chambers + 1), max=4, m=100, d=0, qty=0})
            w.chIdx = #g.chambers
            calc(w); saveData(w)
        elseif w.editParam == 6 then
            if #g.chambers > 1 then
                table.remove(g.chambers, w.chIdx)
                if w.chIdx > #g.chambers then w.chIdx = #g.chambers end
                calc(w); saveData(w)
            end
        else
            w.editMode = 1 - w.editMode
        end
    end

    local isSelChamber = (w.editParam == 1)
    local isEditChamber = (isSelChamber and w.editMode == 1)
    if isEditChamber then
        local stxt = "Chamber " .. w.chIdx .. "/" .. #g.chambers .. ": " .. c.n
        local tw = lcd.getTextWidth and lcd.getTextWidth(stxt, SMLSIZE) or (string.len(stxt) * 6)
        lcd.drawFilledRectangle(ww/2 - tw/2 - 4, 28, tw + 8, 20, RED)
        lcd.drawText(ww/2, 30, stxt, CENTER + SMLSIZE + WHITE)
    else
        lcd.drawText(ww/2, 30, "Chamber " .. w.chIdx .. "/" .. #g.chambers .. ": " .. c.n, CENTER + SMLSIZE + (isSelChamber and RED or BLACK))
    end

    local rows = {
        {label = "Max weights qty", get = function() return tostring(c.max) end},
        {label = "Unit mass (g)", get = function() return tostring(c.m) end},
        {label = "CG Distance (mm)", get = function() return tostring(c.d) end},
    }
    for i, row in ipairs(rows) do
        local y = 52 + (i-1) * 26
        local isSel = (w.editParam == i + 1)
        local isEdit = (isSel and w.editMode == 1)
        drawEditableValue(8, y, row.label .. ": ", row.get(), isSel, isEdit)
    end

    local isSelAdd = (w.editParam == 5)
    local isSelDel = (w.editParam == 6)

    lcd.drawFilledRectangle(8, 134, ww/2 - 12, 24, isSelAdd and ORANGE or BLUE)
    lcd.drawText(8 + (ww/4 - 6), 138, "+ ADD CHAMBER", CENTER + SMLSIZE + WHITE)

    lcd.drawFilledRectangle(ww/2 + 4, 134, ww/2 - 12, 24, isSelDel and ORANGE or RED)
    lcd.drawText(ww/2 + 4 + (ww/4 - 6), 138, "- DELETE", CENTER + SMLSIZE + WHITE)
end

------------------------------------------------------------------
-- PAGE 4: MODEL MANAGEMENT
------------------------------------------------------------------
local function pagegestion(w, ww, hh, event, touchState)
    local g = w.models[w.mIdx]

    local step = getStep(event)
    if step ~= 0 then
        w.actionIdx = w.actionIdx + step
        if w.actionIdx > 3 then w.actionIdx = 1 elseif w.actionIdx < 1 then w.actionIdx = 3 end
    elseif event == EVT_ENTER_BREAK then
        if w.actionIdx == 1 then
            local copy = {}
            for k, v in pairs(g) do copy[k] = v end
            copy.name = string.sub(g.name, 1, 8) .. "-C"
            local chs = {}
            for _, c in ipairs(g.chambers) do table.insert(chs, {n=c.n, max=c.max, m=c.m, d=c.d, qty=0}) end
            copy.chambers = chs
            table.insert(w.models, copy)
            w.mIdx = #w.models
            calc(w); saveData(w)
        elseif w.actionIdx == 2 then
            table.insert(w.models, {name="NEW", emptyW=2000, emptyCG=100, targetCG=100, area=60, vMin=3.0, wMin=2000, vMax=15.0, wMax=3000, chambers={{n="CHMBR1", d=100, m=100, max=4, qty=0}}})
            w.mIdx = #w.models
            calc(w); saveData(w)
        elseif w.actionIdx == 3 then
            if #w.models > 1 then table.remove(w.models, w.mIdx); w.mIdx = 1; calc(w); saveData(w) end
        end
    end

    lcd.drawText(8, 30, "Active model: " .. g.name, SMLSIZE + BLACK)

    local btns = {
        {y=56, label="CLONE active model", color=BLUE},
        {y=92, label="NEW blank model", color=BLUE},
        {y=128, label="DELETE this model", color=RED}
    }
    for i, b in ipairs(btns) do
        local isSel = (w.actionIdx == i)
        if isSel then
            lcd.drawRectangle(6, b.y - 2, ww - 12, 34, ORANGE)
            lcd.drawRectangle(7, b.y - 1, ww - 14, 32, ORANGE)
        end
        lcd.drawFilledRectangle(8, b.y, ww-16, 30, b.color)
        lcd.drawText(ww/2, b.y+7, b.label, CENTER + SMLSIZE + WHITE)
    end
end

------------------------------------------------------------------
-- MAIN REFRESH
------------------------------------------------------------------
local function refresh(w, event, touchState)
    local ww, hh = w.zone.w, w.zone.h

    if type(event) ~= "number" then event = 0 end

    if (EVT_PAGE_BREAK and event == EVT_PAGE_BREAK) or (EVT_VIRTUAL_NEXT_PAGE and event == EVT_VIRTUAL_NEXT_PAGE) then
        w.page = (w.page % 4) + 1
        w.editMode = 0
    elseif (EVT_PAGE_LONG and event == EVT_PAGE_LONG) or (EVT_VIRTUAL_PREV_PAGE and event == EVT_VIRTUAL_PREV_PAGE) then
        w.page = w.page - 1; if w.page < 1 then w.page = 4 end
        w.editMode = 0
    end

    lcd.clear()
    local titles = {"BALLAST - DASHBOARD", "BALLAST - CONFIG & CURVE", "BALLAST - CHAMBERS", "BALLAST - MANAGEMENT"}
    drawHeader(w, ww, titles[w.page])

    if w.page == 1 then pagedashboard(w, ww, hh, event, touchState)
    elseif w.page == 2 then pageconfig(w, ww, hh, event, touchState)
    elseif w.page == 3 then pagesoutes(w, ww, hh, event, touchState)
    elseif w.page == 4 then pagegestion(w, ww, hh, event, touchState) end

    drawTabs(w, ww, hh, touchState)
end

return { name = name, options = options, create = create, update = update, refresh = refresh, background = background }
