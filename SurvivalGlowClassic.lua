-- SurvivalGlow Classic - INVENTORY-BASED VERSION WITH INTERRUPT MODULE
local db = {}

if not SurvivalGlowClassicDB then SurvivalGlowClassicDB = {} end
db = SurvivalGlowClassicDB
if db.th == nil then db.th = 35 end
if db.on == nil then db.on = true end
if not db.enabledIds then db.enabledIds = {} end
if not db.manualIds then db.manualIds = {} end
if not db.interruptOn then db.interruptOn = false end  -- Interrupt mode
if not db.interruptSpells then db.interruptSpells = {} end

print("SurvivalGlow Classic loaded! |cFFFFFF00/sgc|r")

local playerItems = {}
local playerSpells = {}
local playerActionIds = {}
local allGlowIds = {}
local enemyCasting = false

-- Complete survival items
local SURVIVAL_ITEMS = {
    {id=10720,t="item"},{id=10721,t="item"},{id=23826,t="item"},{id=11850,t="item"},{id=12561,t="item"},
    {id=10646,t="item"},{id=4382,t="item"},{id=15137,t="item"},{id=40566,t="item"},{id=40567,t="item"},
    {id=5634,t="item"},{id=13512,t="item"},{id=13511,t="item"},{id=22116,t="item"},{id=17200,t="item"},
    {id=11371,t="item"},{id=11396,t="item"},{id=11348,t="item"},{id=11284,t="item"},{id=22839,t="item"},
    {id=28558,t="item"},{id=39132,t="item"},{id=33448,t="item"},{id=53748,t="item"},{id=53749,t="item"},
    {id=40093,t="item"},{id=40087,t="item"},
    {id=6948,t="item"},{id=2459,t="item"},{id=1191,t="item"},{id=2091,t="item"},{id=3434,t="item"},
    {id=4366,t="item"},{id=4390,t="item"},{id=13506,t="item"},{id=5816,t="item"},{id=5178,t="item"},
    {id=10586,t="item"},
}

-- Survival spells
local SURVIVAL_SPELLS = {
    {id=5384,t="spell"},{id=19263,t="spell"},{id=34471,t="spell"},
    {id=1856,t="spell"},{id=2094,t="spell"},{id=2983,t="spell"},{id=26669,t="spell"},{id=1784,t="spell"},
    {id=11958,t="spell"},{id=1953,t="spell"},{id=122,t="spell"},{id=45438,t="spell"},{id=66,t="spell"},
    {id=20707,t="spell"},{id=6789,t="spell"},{id=18608,t="spell"},{id=47891,t="spell"},
    {id=47585,t="spell"},{id=48173,t="spell"},{id=33206,t="spell"},
    {id=22812,t="spell"},{id=5211,t="spell"},{id=783,t="spell"},{id=1850,t="spell"},{id=106898,t="spell"},
    {id=871,t="spell"},{id=12975,t="spell"},{id=12292,t="spell"},{id=18499,t="spell"},
    {id=642,t="spell"},{id=1022,t="spell"},{id=19753,t="spell"},{id=498,t="spell"},
    {id=2645,t="spell"},{id=546,t="spell"},{id=57960,t="spell"},{id=30823,t="spell"},
    {id=49028,t="spell"},{id=48743,t="spell"},{id=51052,t="spell"},
    {id=20592,t="spell"},{id=20594,t="spell"},{id=20596,t="spell"},
    {id=20580,t="spell"},{id=58984,t="spell"},{id=7744,t="spell"},{id=20577,t="spell"},
    {id=20572,t="spell"},{id=33702,t="spell"},{id=20549,t="spell"},{id=59752,t="spell"},
    {id=26297,t="spell"},{id=20555,t="spell"},{id=54400,t="spell"},
    {id=28730,t="spell"},{id=69179,t="spell"},{id=28880,t="spell"},{id=6562,t="spell"},
}

-- INTERRUPT SPELLS - for interrupt mode
local INTERRUPT_SPELLS = {
    -- Rogue
    {id=1766,t="spell",n="Kick"},{id=1776,t="spell",n="Gouge"},{id=2094,t="spell",n="Blind"},
    -- Warrior
    {id=6552,t="spell",n="Pummel"},{id=72,t="spell",n="Shield Bash"},
    -- Paladin
    {id=96231,t="spell",n="Rebuke"},{id=31935,t="spell",n="Hammer of Justice"},
    -- Hunter
    {id=2139,t="spell",n="Counterattack"},{id=147362,t="spell",n="Countershot"},
    -- Shaman
    {id=8044,t="spell",n="Earth Shock"},{id=8056,t="spell",n="Frost Shock"},
    -- Mage
    {id=2139,t="spell",n="Counterspell"},
    -- Warlock
    {id=19647,t="spell",n="Spell Lock"},
    -- Druid
    {id=78675,t="spell",n="Solar Beam"},
    -- Priest
    {id=15487,t="spell",n="Silence"},
    -- Death Knight
    {id=47528,t="spell",n="Mind Freeze"},
}

-- Scan functions
local function ScanBags()
    wipe(playerItems)
    if GetContainerNumSlots then
        for bag = 0, 4 do
            local slots = GetContainerNumSlots(bag)
            if slots and slots > 0 then
                for slot = 1, slots do
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID then playerItems[itemID] = true end
                end
            end
        end
    end
end

local function ScanSpells()
    wipe(playerSpells)
    for i = 1, 1000 do
        local spellType, spellID = GetSpellBookItemInfo(i, "spell")
        if spellType == "SPELL" then playerSpells[spellID] = true end
    end
end

local function ScanActionBars()
    wipe(playerActionIds)
    local bars = {"ActionButton","MultiBarRightButton","MultiBarLeftButton","MultiBarBottomRightButton","MultiBarBottomLeftButton"}
    for _,bar in ipairs(bars) do
        for i = 1, 12 do
            local btn = _G[bar..i]
            if btn then
                local action = btn.action
                if action and action > 0 then
                    local type, id = GetActionInfo(action)
                    if id then
                        if type == "item" then playerActionIds["item:"..id] = true
                        elseif type == "spell" then playerActionIds["spell:"..id] = true end
                    end
                end
            end
        end
    end
end

-- Build glow list
local function BuildGlowList()
    wipe(allGlowIds)
    
    -- Survival items
    for _,v in ipairs(SURVIVAL_ITEMS) do
        local key = "item:" .. v.id
        if playerItems[v.id] or playerActionIds[key] then
            if db.enabledIds[key] == nil then db.enabledIds[key] = true end
        end
    end
    
    -- Survival spells
    for _,v in ipairs(SURVIVAL_SPELLS) do
        local key = "spell:" .. v.id
        if playerSpells[v.id] or playerActionIds[key] then
            local tex = GetSpellTexture(v.id)
            if tex and db.enabledIds[key] == nil then db.enabledIds[key] = true end
        end
    end
    
    -- Interrupt spells - only if interrupt mode is on
    if db.interruptOn then
        for _,v in ipairs(INTERRUPT_SPELLS) do
            local key = "spell:" .. v.id
            if playerSpells[v.id] or playerActionIds[key] then
                if db.interruptSpells[key] == nil then db.interruptSpells[key] = true end
            end
        end
    end
    
    for id, enabled in pairs(db.enabledIds) do if enabled then allGlowIds[id] = true end end
    for id, enabled in pairs(db.interruptSpells) do if enabled then allGlowIds[id] = true end end
    for id,_ in pairs(db.manualIds) do allGlowIds[id] = true end
end

local scanCooldown = 0
local function FullScan()
    local now = GetTime()
    if now < scanCooldown then return end
    scanCooldown = now + 2
    ScanBags(); ScanSpells(); ScanActionBars(); BuildGlowList()
end

-- Get all buttons
local function GetAllButtons()
    local buttons = {}
    local bars = {"ActionButton","MultiBarRightButton","MultiBarLeftButton","MultiBarBottomRightButton","MultiBarBottomLeftButton"}
    for _,bar in ipairs(bars) do for i = 1,12 do table.insert(buttons, bar..i) end end
    for name, obj in pairs(_G) do
        if type(obj)=="table" then
            local ok, isBtn = pcall(function() return obj.IsObjectType and obj:IsObjectType("Button") end)
            if ok and isBtn then
                local n = obj:GetName()
                if n and n~="" and not buttons[n] and obj.action then table.insert(buttons,n) end
            end
        end
    end
    return buttons
end

-- Glow functions
local glows = {}
local function ShowGlow(btn)
    if glows[btn] then return end
    if ActionButton_ShowOverlayGlow then ActionButton_ShowOverlayGlow(btn); glows[btn]=true
    elseif btn.ShowOverlayGlow then btn:ShowOverlayGlow(); glows[btn]=true end
end

local function HideGlow(btn)
    if not glows[btn] then return end
    if ActionButton_HideOverlayGlow then ActionButton_HideOverlayGlow(btn); glows[btn]=nil
    elseif btn.HideOverlayGlow then btn:HideOverlayGlow(); glows[btn]=nil end
end

local function IsOnCooldown(actionType, id)
    if actionType == "spell" then
        local s,d = GetSpellCooldown(id)
        if s and s>0 and d and d>0 then return true end
    end
    return false
end

local function Glow()
    local buttonList = GetAllButtons()
    for _,btnName in ipairs(buttonList) do
        local btn = _G[btnName]
        if btn and btn:IsVisible() then
            local action = btn.action or 0
            if action > 0 then
                local actionType, id = GetActionInfo(action)
                if id then
                    local checkId = actionType..":"..id
                    if allGlowIds[checkId] and not IsOnCooldown(actionType,id) then
                        ShowGlow(btn)
                    end
                end
            end
        end
    end
end

local function ClearAll()
    for _,btnName in ipairs(GetAllButtons()) do
        local btn = _G[btnName]
        if btn then HideGlow(btn) end
    end
end

-- Check health (survival mode)
function Check()
    if not db.on then ClearAll(); return end
    local hp = UnitHealth("player")/UnitHealthMax("player")*100
    if hp <= db.th then Glow() else ClearAll() end
end

-- Check interrupts when enemy is casting
local function CheckInterrupt()
    if not db.interruptOn then
        if enemyCasting then ClearAll(); enemyCasting=false end
        return
    end
    
    if enemyCasting then
        -- Only glow interrupt spells, not survival spells
        local buttonList = GetAllButtons()
        for _,btnName in ipairs(buttonList) do
            local btn = _G[btnName]
            if btn and btn:IsVisible() then
                local action = btn.action or 0
                if action > 0 then
                    local actionType, id = GetActionInfo(action)
                    if id then
                        local checkId = actionType..":"..id
                        -- Only check interrupt spells, not survival
                        if db.interruptSpells[checkId] and not IsOnCooldown(actionType,id) then
                            ShowGlow(btn)
                        end
                    end
                end
            end
        end
    else
        ClearAll()
    end
end

-- Events
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("SPELLS_CHANGED")
f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f:RegisterEvent("UNIT_SPELLCAST_START")  -- Enemy started casting
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")  -- Enemy finished casting
f:SetScript("OnEvent", function(_,e,u)
    if e == "UNIT_HEALTH" and u == "player" then
        Check()
    elseif e == "UNIT_SPELLCAST_START" and u ~= "player" then
        -- Enemy is casting
        enemyCasting = true
        CheckInterrupt()
    elseif e == "UNIT_SPELLCAST_SUCCEEDED" and u ~= "player" then
        -- Enemy finished casting
        enemyCasting = false
        CheckInterrupt()
    else
        C_Timer.After(0.5, function() FullScan(); if frame and frame:IsVisible() then RefreshFrame() end end)
    end
end)

-- Forward declaration
local RefreshFrame

-- Slash commands
SLASH_SGC1 = "/sgc"
SlashCmdList["SGC"] = function(msg)
    if msg == "test" then Glow(); C_Timer.NewTimer(10, ClearAll)
    elseif msg == "on" then db.on=true; print("SurvivalGlow enabled"); Check()
    elseif msg == "off" then db.on=false; print("SurvivalGlow disabled"); ClearAll()
    elseif msg == "scan" then FullScan()
    elseif msg == "int" then db.interruptOn = not db.interruptOn; print("Interrupt mode:", db.interruptOn); BuildGlowList(); CheckInterrupt()
    else if SGC_ConfigFrame then SGC_ConfigFrame:Show() end end
end

-- Config Frame
local frame = CreateFrame("Frame", "SGC_ConfigFrame", UIParent, "BackdropTemplate")
frame:SetSize(450, 650)
frame:SetPoint("CENTER")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
frame:Hide()
frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile=true, edgeSize=32, tileSize=32, insets={left=8,right=8,top=8,bottom=8}})

local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("SurvivalGlow")

local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() frame:Hide() end)

local scanBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
scanBtn:SetPoint("TOPRIGHT", -30, -15); scanBtn:SetSize(60,20); scanBtn:SetText("Scan")
scanBtn:SetScript("OnClick", FullScan)

local infoText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
infoText:SetPoint("TOPLEFT", 20, -35)
frame.infoText = infoText

-- Survival settings
local enableCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", 20, -55)
enableCheck:SetChecked(db.on)
enableCheck.Text:SetText("Survival Glow (Low HP)")
enableCheck:SetScript("OnClick", function() db.on = enableCheck:GetChecked(); Check() end)

local threshLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
threshLabel:SetPoint("TOPLEFT", 20, -85)
threshLabel:SetText("Health %: " .. db.th)

local threshSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
threshSlider:SetPoint("TOPLEFT", 130, -85); threshSlider:SetSize(180,20); threshSlider:SetMinMaxValues(1,100); threshSlider:SetValue(db.th)
threshSlider:SetScript("OnValueChanged", function() db.th=math.floor(threshSlider:GetValue()); threshLabel:SetText("Health %: "..db.th); Check() end)

-- INTERRUPT MODE TOGGLE
local intCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
intCheck:SetPoint("TOPLEFT", 20, -115)
intCheck:SetChecked(db.interruptOn)
intCheck.Text:SetText("Interrupt Glow (Enemy Casting)")
intCheck:SetScript("OnClick", function() 
    db.interruptOn = intCheck:GetChecked()
    BuildGlowList()
    if db.interruptOn then CheckInterrupt() else if enemyCasting then enemyCasting=false; ClearAll() end end
end)

local intInfo = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
intInfo:SetPoint("TOPLEFT", 25, -135)
intInfo:SetText("Glows Kick/Gouge/Blind when enemy casts")

-- Manual ID input
local idLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
idLabel:SetPoint("TOPLEFT", 20, -160)
idLabel:SetText("Add ID:")

local idEdit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
idEdit:SetPoint("TOPLEFT", 90, -160); idEdit:SetSize(80,20); idEdit:SetNumeric(true)

local typeEdit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
typeEdit:SetPoint("LEFT", idEdit, "RIGHT", 5, 0); typeEdit:SetSize(50,20); typeEdit:SetMaxLetters(5); typeEdit:SetText("item")

local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetPoint("LEFT", typeEdit, "RIGHT", 10, 0); addBtn:SetSize(50,20); addBtn:SetText("Add")
addBtn:SetScript("OnClick", function()
    local id = tonumber(idEdit:GetText())
    local idType = strlower(typeEdit:GetText())
    if id and (idType=="item" or idType=="spell") then
        local key = idType..":"..id
        db.manualIds[key] = true
        BuildGlowList()
        print("Added:", key)
        RefreshFrame()
    end
end)

local listLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
listLabel:SetPoint("TOPLEFT", 20, -190)
frame.listLabel = listLabel

local listScroll = CreateFrame("ScrollFrame", "SGC_ListScroll", frame, "UIPanelScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT", 20, -210); listScroll:SetSize(410, 350)
local listChild = CreateFrame("Frame")
listChild:SetSize(410, 1500)
listScroll:SetScrollChild(listChild)
frame.listChild = listChild

local function RefreshFrame()
    enableCheck:SetChecked(db.on)
    intCheck:SetChecked(db.interruptOn)
    threshSlider:SetValue(db.th)
    threshLabel:SetText("Health %: " .. db.th)
    
    infoText:SetText("Bags: " .. (next(playerItems) and "scanned" or "empty") .. " | Spells: " .. (next(playerSpells) and "scanned" or "empty"))
    
    local count = 0
    for k,v in pairs(db.enabledIds) do if v then count = count + 1 end end
    for k,v in pairs(db.interruptSpells) do if v then count = count + 1 end end
    for k,v in pairs(db.manualIds) do if v then count = count + 1 end end
    
    listLabel:SetText("Enabled (" .. count .. "):")
    
    for _,c in ipairs({frame.listChild:GetChildren()}) do c:Hide() end
    local y = 0
    
    -- Survival items
    for _,v in ipairs(SURVIVAL_ITEMS) do
        local key = "item:" .. v.id
        if playerItems[v.id] or playerActionIds[key] then
            local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
            chk:SetPoint("TOPLEFT", 0, -y)
            chk:SetChecked(db.enabledIds[key] ~= false)
            chk:SetScript("OnClick", function() db.enabledIds[key]=chk:GetChecked(); BuildGlowList(); Check() end)
            
            local tex = frame.listChild:CreateTexture(nil, "ARTWORK")
            tex:SetSize(16,16); tex:SetPoint("LEFT", chk, "RIGHT", 2, 0)
            tex:SetTexture(GetItemIcon(v.id) or "Interface/Icons/INV_Misc_QuestionMark")
            
            local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            txt:SetPoint("LEFT", tex, "RIGHT", 4, 0); txt:SetText("Item: " .. v.id)
            
            y = y + 20
        end
    end
    
    -- Survival spells
    for _,v in ipairs(SURVIVAL_SPELLS) do
        local key = "spell:" .. v.id
        if playerSpells[v.id] or playerActionIds[key] then
            local tex = GetSpellTexture(v.id)
            if tex then
                local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
                chk:SetPoint("TOPLEFT", 0, -y)
                chk:SetChecked(db.enabledIds[key] ~= false)
                chk:SetScript("OnClick", function() db.enabledIds[key]=chk:GetChecked(); BuildGlowList(); Check() end)
                
                local t = frame.listChild:CreateTexture(nil, "ARTWORK")
                t:SetSize(16,16); t:SetPoint("LEFT", chk, "RIGHT", 2, 0); t:SetTexture(tex)
                
                local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                txt:SetPoint("LEFT", t, "RIGHT", 4, 0); txt:SetText("Spell: " .. v.id)
                
                y = y + 20
            end
        end
    end
    
    -- Interrupt spells (if enabled)
    if db.interruptOn then
        for _,v in ipairs(INTERRUPT_SPELLS) do
            local key = "spell:" .. v.id
            if playerSpells[v.id] or playerActionIds[key] then
                local tex = GetSpellTexture(v.id)
                if tex then
                    local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
                    chk:SetPoint("TOPLEFT", 0, -y)
                    chk:SetChecked(db.interruptSpells[key] ~= false)
                    chk:SetScript("OnClick", function() db.interruptSpells[key]=chk:GetChecked(); BuildGlowList(); CheckInterrupt() end)
                    
                    local t = frame.listChild:CreateTexture(nil, "ARTWORK")
                    t:SetSize(16,16); t:SetPoint("LEFT", chk, "RIGHT", 2, 0); t:SetTexture(tex)
                    
                    local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                    txt:SetPoint("LEFT", t, "RIGHT", 4, 0); txt:SetText(v.n or "Spell: "..v.id)
                    
                    y = y + 20
                end
            end
        end
    end
    
    -- Manual IDs
    for id,_ in pairs(db.manualIds) do
        local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
        chk:SetPoint("TOPLEFT", 0, -y); chk:SetChecked(true)
        chk:SetScript("OnClick", function() db.manualIds[id]=nil; BuildGlowList(); Check(); RefreshFrame() end)
        
        local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", chk, "RIGHT", 4, 0); txt:SetText(id .. " (manual)")
        
        y = y + 20
    end
    
    frame.listChild:SetHeight(math.max(1500, y+20))
end

frame:SetScript("OnShow", function() FullScan(); RefreshFrame() end)

print("Type |cFFFFFF00/sgc|r config, |cFFFFFF00/sgc scan|r rescan, |cFFFFFF00/sgc int|r toggle interrupt")
