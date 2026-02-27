-- SurvivalGlow Classic - INVENTORY-BASED VERSION
local db = {}

if not SurvivalGlowClassicDB then SurvivalGlowClassicDB = {} end
db = SurvivalGlowClassicDB
if db.th == nil then db.th = 35 end
if db.on == nil then db.on = true end
if not db.enabledIds then db.enabledIds = {} end  -- Store IDs as strings "type:id"
if not db.manualIds then db.manualIds = {} end  -- User-added IDs

print("SurvivalGlow Classic loaded! |cFFFFFF00/sgc|r")

local playerItems = {}  -- Items in bags
local playerSpells = {}  -- Known spells
local playerActionIds = {}  -- IDs on action bars
local allGlowIds = {}  -- All IDs to check for glow

-- Complete survival items/spells database (for reference)
local SURVIVAL_ITEMS = {
    -- Engineering (164)
    {id=10720,t="item"},{id=10721,t="item"},{id=23826,t="item"},{id=11850,t="item"},{id=12561,t="item"},
    {id=10646,t="item"},{id=4382,t="item"},{id=15137,t="item"},{id=40566,t="item"},{id=40567,t="item"},
    -- Alchemy (171)
    {id=5634,t="item"},{id=13512,t="item"},{id=13511,t="item"},{id=22116,t="item"},{id=17200,t="item"},
    {id=11371,t="item"},{id=11396,t="item"},{id=11348,t="item"},{id=11284,t="item"},{id=22839,t="item"},
    {id=28558,t="item"},{id=39132,t="item"},{id=33448,t="item"},{id=53748,t="item"},{id=53749,t="item"},
    {id=40093,t="item"},{id=40087,t="item"},
    -- Universal
    {id=6948,t="item"},{id=2459,t="item"},{id=1191,t="item"},{id=2091,t="item"},{id=3434,t="item"},
    {id=4366,t="item"},{id=4390,t="item"},{id=13506,t="item"},{id=5816,t="item"},{id=5178,t="item"},
    {id=10586,t="item"},
}

-- Deduplicated spell list
local SURVIVAL_SPELLS = {
    -- Hunter
    {id=5384,t="spell",n="Feign Death"},{id=19263,t="spell",n="Deterrence"},{id=34471,t="spell",n="Misdirection"},
    -- Rogue
    {id=1856,t="spell",n="Vanish"},{id=2094,t="spell",n="Blind"},{id=2983,t="spell",n="Sprint"},{id=26669,t="spell",n="Evasion"},{id=1784,t="spell",n="Stealth"},
    -- Mage
    {id=11958,t="spell",n="Ice Block"},{id=1953,t="spell",n="Blink"},{id=122,t="spell",n="Frost Nova"},{id=45438,t="spell",n="Ice Barrier"},{id=66,t="spell",n="Invisibility"},
    -- Warlock
    {id=20707,t="spell",n="Soulstone"},{id=6789,t="spell",n="Death Coil"},{id=18608,t="spell",n="Shadow Ward"},{id=47891,t="spell",n="Unending Resolve"},
    -- Priest
    {id=47585,t="spell",n="Dispersion"},{id=48173,t="spell",n="Desperate Prayer"},{id=33206,t="spell",n="Pain Suppression"},
    -- Druid
    {id=22812,t="spell",n="Barkskin"},{id=5211,t="spell",n="Bash"},{id=783,t="spell",n="Travel Form"},{id=1850,t="spell",n="Dash"},{id=106898,t="spell",n="Stampede"},
    -- Warrior
    {id=871,t="spell",n="Shield Wall"},{id=12975,t="spell",n="Last Stand"},{id=12292,t="spell",n="Death Wish"},{id=18499,t="spell",n="Berserker Rage"},
    -- Paladin
    {id=642,t="spell",n="Divine Shield"},{id=1022,t="spell",n="Blessing of Protection"},{id=19753,t="spell",n="Divine Intervention"},{id=498,t="spell",n="Divine Protection"},
    -- Shaman
    {id=2645,t="spell",n="Ghost Wolf"},{id=546,t="spell",n="Water Walking"},{id=57960,t="spell",n="Nature's Swiftness"},{id=30823,t="spell",n="Shamanistic Rage"},
    -- Death Knight
    {id=49028,t="spell",n="Icebound Fortitude"},{id=48743,t="spell",n="Death Pact"},{id=51052,t="spell",n="Anti-Magic Zone"},
    -- Racials (no duplicates)
    {id=20592,t="spell",n="Engineering Specialist"},
    {id=20594,t="spell",n="Stoneform"},{id=20596,t="spell",n="Might of the Mountain"},
    {id=20580,t="spell",n="Shadowmeld"},{id=58984,t="spell",n="Shadowmeld (Racial)"},
    {id=7744,t="spell",n="Will of the Forsaken"},{id=20577,t="spell",n="Cannibalize"},
    {id=20572,t="spell",n="Blood Fury"},{id=33702,t="spell",n="Blood Fury (Phys)"},
    {id=20549,t="spell",n="War Stomp"},{id=59752,t="spell",n="Every Man for Himself"},
    {id=26297,t="spell",n="Berserking"},{id=20555,t="spell",n="Regeneration"},
    {id=54400,t="spell",n="Diplomacy"},
    {id=28730,t="spell",n="Arcane Torrent"},{id=69179,t="spell",n="Heroism"},
    {id=28880,t="spell",n="Gift of the Naaru"},{id=6562,t="spell",n="Heroic Presence"},
}

-- Scan player bags
local function ScanBags()
    wipe(playerItems)
    -- Try to scan bags, but handle errors gracefully
    if GetContainerNumSlots then
        for bag = 0, 4 do
            local slots = GetContainerNumSlots(bag)
            if slots and slots > 0 then
                for slot = 1, slots do
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID then
                        playerItems[itemID] = true
                    end
                end
            end
        end
    end
end

-- Scan known spells
local function ScanSpells()
    wipe(playerSpells)
    -- Try to scan spellbook, but handle errors gracefully
    for i = 1, 1000 do
        local spellType, spellID = GetSpellBookItemInfo(i, "spell")
        if spellType == "SPELL" then
            playerSpells[spellID] = true
        end
    end
end

-- Scan action bars for items/spells
local function ScanActionBars()
    wipe(playerActionIds)
    -- Scan all standard action buttons
    for i = 1, 12 do
        local btn = _G["ActionButton"..i]
        if btn then
            local action = btn.action
            if action and action > 0 then
                local type, id = GetActionInfo(action)
                if id then
                    if type == "item" then
                        playerActionIds["item:"..id] = true
                    elseif type == "spell" then
                        playerActionIds["spell:"..id] = true
                    end
                end
            end
        end
    end
    -- Scan MultiBarRight
    for i = 1, 12 do
        local btn = _G["MultiBarRightButton"..i]
        if btn then
            local action = btn.action
            if action and action > 0 then
                local type, id = GetActionInfo(action)
                if id then
                    if type == "item" then
                        playerActionIds["item:"..id] = true
                    elseif type == "spell" then
                        playerActionIds["spell:"..id] = true
                    end
                end
            end
        end
    end
    -- Scan MultiBarLeft
    for i = 1, 12 do
        local btn = _G["MultiBarLeftButton"..i]
        if btn then
            local action = btn.action
            if action and action > 0 then
                local type, id = GetActionInfo(action)
                if id then
                    if type == "item" then
                        playerActionIds["item:"..id] = true
                    elseif type == "spell" then
                        playerActionIds["spell:"..id] = true
                    end
                end
            end
        end
    end
    -- Scan MultiBarBottomRight
    for i = 1, 12 do
        local btn = _G["MultiBarBottomRightButton"..i]
        if btn then
            local action = btn.action
            if action and action > 0 then
                local type, id = GetActionInfo(action)
                if id then
                    if type == "item" then
                        playerActionIds["item:"..id] = true
                    elseif type == "spell" then
                        playerActionIds["spell:"..id] = true
                    end
                end
            end
        end
    end
    -- Scan MultiBarBottomLeft
    for i = 1, 12 do
        local btn = _G["MultiBarBottomLeftButton"..i]
        if btn then
            local action = btn.action
            if action and action > 0 then
                local type, id = GetActionInfo(action)
                if id then
                    if type == "item" then
                        playerActionIds["item:"..id] = true
                    elseif type == "spell" then
                        playerActionIds["spell:"..id] = true
                    end
                end
            end
        end
    end
end

-- Check if player has item/spell
local function PlayerHas(id, idType)
    if idType == "item" then
        return playerItems[id] or playerActionIds["item:"..id]
    else
        return playerSpells[id] or playerActionIds["spell:"..id]
    end
end

-- Build list of glow IDs
local function BuildGlowList()
    wipe(allGlowIds)
    
    -- Auto-enable items/spells player has that are in our database
    for _,v in ipairs(SURVIVAL_ITEMS) do
        local key = "item:" .. v.id
        if playerItems[v.id] or playerActionIds[key] then
            if db.enabledIds[key] == nil then
                db.enabledIds[key] = true  -- Auto-enable
            end
        end
    end
    for _,v in ipairs(SURVIVAL_SPELLS) do
        local key = "spell:" .. v.id
        if playerSpells[v.id] or playerActionIds[key] then
            -- Only auto-enable if spell has a valid texture
            local tex = GetSpellTexture(v.id)
            if tex then
                if db.enabledIds[key] == nil then
                    db.enabledIds[key] = true  -- Auto-enable
                end
            end
        end
    end
    
    -- Add enabled items from database
    for id, enabled in pairs(db.enabledIds) do
        if enabled then
            allGlowIds[id] = true
        end
    end
    
    -- Add manual IDs
    for id, _ in pairs(db.manualIds) do
        allGlowIds[id] = true
    end
end

-- Scan and rebuild
local function FullScan()
    ScanBags()
    ScanSpells()
    ScanActionBars()
    BuildGlowList()
    print("Scanned - Items:", #playerItems, "Spells:", #playerSpells)
end

-- Find ALL action buttons
local function GetAllButtons()
    local buttons = {}
    for i = 1, 12 do table.insert(buttons, "ActionButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarRightButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarLeftButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarBottomRightButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarBottomLeftButton" .. i) end
    
    for name, obj in pairs(_G) do
        if type(obj) == "table" then
            local success, isButton = pcall(function() return obj.IsObjectType and obj:IsObjectType("Button") end)
            if success and isButton then
                local n = obj:GetName()
                if n and n ~= "" and not buttons[n] then
                    if obj.action then
                        table.insert(buttons, n)
                    end
                end
            end
        end
    end
    return buttons
end

-- Use WoW's built-in glow
local glows = {}

local function ShowGlow(btn)
    if glows[btn] then return end
    if ActionButton_ShowOverlayGlow then
        ActionButton_ShowOverlayGlow(btn)
        glows[btn] = true
    elseif btn.ShowOverlayGlow then
        btn:ShowOverlayGlow()
        glows[btn] = true
    end
end

local function HideGlow(btn)
    if not glows[btn] then return end
    if ActionButton_HideOverlayGlow then
        ActionButton_HideOverlayGlow(btn)
        glows[btn] = nil
    elseif btn.HideOverlayGlow then
        btn:HideOverlayGlow()
        glows[btn] = nil
    end
end

-- Check cooldown
local function IsOnCooldown(actionType, id)
    if actionType == "spell" then
        local start, duration = GetSpellCooldown(id)
        if start and start > 0 and duration and duration > 0 then
            return true
        end
    end
    return false
end

local function Glow()
    local buttonList = GetAllButtons()
    
    for _, btnName in ipairs(buttonList) do
        local btn = _G[btnName]
        if btn and btn:IsVisible() then
            local action = btn.action or 0
            if action > 0 then
                local actionType, id = GetActionInfo(action)
                if id then
                    local checkId = actionType .. ":" .. id
                    if allGlowIds[checkId] and not IsOnCooldown(actionType, id) then
                        ShowGlow(btn)
                    end
                end
            end
        end
    end
end

local function ClearAll()
    local buttonList = GetAllButtons()
    for _, btnName in ipairs(buttonList) do
        local btn = _G[btnName]
        if btn then HideGlow(btn) end
    end
end

function Check()
    if not db.on then ClearAll(); return end
    local hp = UnitHealth("player")/UnitHealthMax("player")*100
    if hp <= db.th then Glow() else ClearAll() end
end

SLASH_SGC1 = "/sgc"
SlashCmdList["SGC"] = function(msg)
    if msg == "test" then
        Glow()
        C_Timer.NewTimer(10, function() ClearAll() end)
    elseif msg == "on" then
        db.on = true
        print("SurvivalGlow enabled")
        Check()
    elseif msg == "off" then
        db.on = false
        print("SurvivalGlow disabled")
        ClearAll()
    elseif msg == "scan" then
        FullScan()
    else
        if SGC_ConfigFrame then SGC_ConfigFrame:Show() end
    end
end

-- Config Frame
local frame = CreateFrame("Frame", "SGC_ConfigFrame", UIParent, "BackdropTemplate")
frame:SetSize(450, 600)
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
scanBtn:SetPoint("TOPRIGHT", -30, -15)
scanBtn:SetSize(60, 20)
scanBtn:SetText("Scan")
scanBtn:SetScript("OnClick", function() FullScan() end)

local infoText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
infoText:SetPoint("TOPLEFT", 20, -35)
frame.infoText = infoText

local enableCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", 20, -55)
enableCheck:SetChecked(db.on)
enableCheck.Text:SetText("Enable")
enableCheck:SetScript("OnClick", function() db.on = enableCheck:GetChecked(); Check() end)

local threshLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
threshLabel:SetPoint("TOPLEFT", 20, -85)
threshLabel:SetText("Health %: " .. db.th)

local threshSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
threshSlider:SetPoint("TOPLEFT", 130, -85)
threshSlider:SetSize(180, 20)
threshSlider:SetMinMaxValues(1, 100)
threshSlider:SetValue(db.th)
threshSlider:SetScript("OnValueChanged", function() 
    db.th = math.floor(threshSlider:GetValue()) 
    threshLabel:SetText("Health %: " .. db.th)
    Check() 
end)

-- Manual ID input
local idLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
idLabel:SetPoint("TOPLEFT", 20, -115)
idLabel:SetText("Add Item/Spell ID:")

local idEdit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
idEdit:SetPoint("TOPLEFT", 150, -115)
idEdit:SetSize(100, 20)
idEdit:SetNumeric(true)
idEdit:SetMaxLetters(8)

local typeLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
typeLabel:SetPoint("LEFT", idEdit, "RIGHT", 5, 0)
typeLabel:SetText("Type:")

local typeEdit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
typeEdit:SetPoint("LEFT", typeLabel, "RIGHT", 5, 0)
typeEdit:SetSize(50, 20)
typeEdit:SetMaxLetters(5)
typeEdit:SetText("item")

local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetPoint("LEFT", typeEdit, "RIGHT", 10, 0)
addBtn:SetSize(50, 20)
addBtn:SetText("Add")
addBtn:SetScript("OnClick", function()
    local id = tonumber(idEdit:GetText())
    local idType = strlower(typeEdit:GetText())
    if id and (idType == "item" or idType == "spell") then
        local key = idType .. ":" .. id
        db.manualIds[key] = true
        BuildGlowList()
        print("Added:", key)
        RefreshFrame()
    end
end)

local listLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
listLabel:SetPoint("TOPLEFT", 20, -145)
frame.listLabel = listLabel

local listScroll = CreateFrame("ScrollFrame", "SGC_ListScroll", frame, "UIPanelScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT", 20, -165)
listScroll:SetSize(410, 350)
local listChild = CreateFrame("Frame")
listChild:SetSize(410, 1000)
listScroll:SetScrollChild(listChild)
frame.listChild = listChild

local function RefreshFrame()
    enableCheck:SetChecked(db.on)
    threshSlider:SetValue(db.th)
    threshLabel:SetText("Health %: " .. db.th)
    
    -- Update info
    local info = "Bags: " .. (next(playerItems) and "scanned" or "empty") .. " | Spells: " .. (next(playerSpells) and "scanned" or "empty")
    infoText:SetText(info)
    
    -- Count enabled
    local count = 0
    for k,v in pairs(db.enabledIds) do if v then count = count + 1 end end
    for k,v in pairs(db.manualIds) do if v then count = count + 1 end end
    
    listLabel:SetText("Enabled IDs (" .. count .. "):")
    
    -- Show list
    for _,c in ipairs({frame.listChild:GetChildren()}) do c:Hide() end
    local y = 0
    local count2 = 0
    
    -- Show enabled from survival database that player has
    for _,v in ipairs(SURVIVAL_ITEMS) do
        local key = "item:" .. v.id
        if playerItems[v.id] or playerActionIds[key] then
            local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
            chk:SetPoint("TOPLEFT", 0, -y)
            chk:SetChecked(db.enabledIds[key] ~= false)
            chk:SetScript("OnClick", function() 
                db.enabledIds[key] = chk:GetChecked()
                BuildGlowList()
                Check() 
            end)
            
            local tex = frame.listChild:CreateTexture(nil, "ARTWORK")
            tex:SetSize(16,16)
            tex:SetPoint("LEFT", chk, "RIGHT", 2, 0)
            local icn = GetItemIcon(v.id)
            if icn then tex:SetTexture(icn) else tex:SetColorTexture(0.5,0.5,0.5) end
            
            local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            txt:SetPoint("LEFT", tex, "RIGHT", 4, 0)
            txt:SetText("Item: " .. v.id)
            
            y = y + 20
            count2 = count2 + 1
            if count2 > 200 then break end
        end
    end
    
    for _,v in ipairs(SURVIVAL_SPELLS) do
        local key = "spell:" .. v.id
        if playerSpells[v.id] or playerActionIds[key] then
            local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
            chk:SetPoint("TOPLEFT", 0, -y)
            chk:SetChecked(db.enabledIds[key] ~= false)
            chk:SetScript("OnClick", function() 
                db.enabledIds[key] = chk:GetChecked()
                BuildGlowList()
                Check() 
            end)
            
            local tex = frame.listChild:CreateTexture(nil, "ARTWORK")
            tex:SetSize(16,16)
            tex:SetPoint("LEFT", chk, "RIGHT", 2, 0)
            local icn = GetSpellTexture(v.id)
            if icn then tex:SetTexture(icn) else tex:SetColorTexture(0.5,0.5,0.5) end
            
            local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            txt:SetPoint("LEFT", tex, "RIGHT", 4, 0)
            txt:SetText("Spell: " .. v.id)
            
            y = y + 20
            count2 = count2 + 1
            if count2 > 200 then break end
        end
    end
    
    -- Show manual IDs
    for id,_ in pairs(db.manualIds) do
        local chk = CreateFrame("CheckButton", nil, frame.listChild, "InterfaceOptionsCheckButtonTemplate")
        chk:SetPoint("TOPLEFT", 0, -y)
        chk:SetChecked(true)
        chk:SetScript("OnClick", function() 
            db.manualIds[id] = nil
            BuildGlowList()
            Check()
            RefreshFrame()
        end)
        
        local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", chk, "RIGHT", 4, 0)
        txt:SetText(id .. " (manual)")
        
        y = y + 20
        count2 = count2 + 1
    end
    
    if count2 == 0 then
        local txt = frame.listChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("TOPLEFT", 0, 0)
        txt:SetText("Click 'Scan' to find items/spells in your bags and on action bars")
    end
    
    frame.listChild:SetHeight(math.max(1000, y + 20))
end

frame:SetScript("OnShow", function()
    FullScan()
    RefreshFrame()
end)

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("SPELLS_CHANGED")
f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f:SetScript("OnEvent", function(_,e,u)
    if e == "UNIT_HEALTH" and u == "player" then
        Check()
    else
        C_Timer.After(0.5, function() FullScan(); if frame:IsVisible() then RefreshFrame() end end)
    end
end)

print("Type |cFFFFFF00/sgc|r to open config, |cFFFFFF00/sgc scan|r to rescan")
