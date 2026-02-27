-- SurvivalGlow Classic - FULL VERSION
local db = {}

-- Default items
local DEFAULT_ITEMS = {
    {id=6948,n="Hearthstone"},
    {id=2459,n="Swiftness Potion"},
    {id=1191,n="Bag of Marbles"},
    {id=2091,n="Magic Dust"},
    {id=3434,n="Slumber Sand"},
    {id=4366,n="Target Dummy"},
    {id=4390,n="Iron Grenade"},
    {id=10646,n="Goblin Sapper Charge"},
    {id=13506,n="Flask of Petrification"},
    {id=5816,n="Light of Elune"},
    {id=5178,n="Noggenfogger Elixir"},
    {id=10586,n="Gnomish Mind Control Cap"},
    {id=10720,n="Gnomish Rocket Boots"},
    {id=10721,n="Goblin Rocket Boots"},
    {id=23826,n="Gnomish Rocket Boots"},
}

-- Class spells
local ALL_CLASS_SPELLS = {
    ["HUNTER"] = {{id=5384,n="Feign Death"},{id=19263,n="Deterrence"}},
    ["ROGUE"] = {{id=1856,n="Vanish"},{id=2094,n="Blind"},{id=2983,n="Sprint"},{id=26669,n="Evasion"},{id=20589,n="Escape Artist"}},
    ["MAGE"] = {{id=11958,n="Ice Block"},{id=1953,n="Blink"},{id=122,n="Frost Nova"}},
    ["WARLOCK"] = {{id=20707,n="Soulstone"},{id=6789,n="Death Coil"}},
    ["PRIEST"] = {{id=47585,n="Dispersion"}},
    ["DRUID"] = {{id=22812,n="Barkskin"},{id=5211,n="Bash"}},
    ["WARRIOR"] = {{id=871,n="Shield Wall"},{id=12975,n="Last Stand"}},
    ["PALADIN"] = {{id=642,n="Divine Shield"},{id=1022,n="Blessing of Protection"}},
    ["SHAMAN"] = {{id=2645,n="Ghost Wolf"}},
    ["DEATHKNIGHT"] = {{id=49028,n="Icebound Fortitude"}},
    ["GNOME"] = {{id=20589,n="Escape Artist"}},
    ["DWARF"] = {{id=20594,n="Stoneform"}},
    ["NIGHTELF"] = {{id=20580,n="Shadowmeld"}},
    ["UNDEAD"] = {{id=7744,n="Will of the Forsaken"}},
}

if not SurvivalGlowClassicDB then SurvivalGlowClassicDB = {} end
db = SurvivalGlowClassicDB
if db.th == nil then db.th = 35 end
if db.on == nil then db.on = true end
if not db.enabledSpells then db.enabledSpells = {} end
if not db.enabledItems then db.enabledItems = {} end

print("SurvivalGlow Classic loaded! |cFFFFFF00/sgc|r")

local _, playerClass = UnitClass("player")
local playerRace = UnitRace("player")
local allAvailableSpells = {}
local allAvailableItems = {}
local itemIds = {}
local spellIds = {}

local function RebuildLookups()
    wipe(itemIds)
    wipe(spellIds)
    wipe(allAvailableSpells)
    wipe(allAvailableItems)
    
    if playerClass and ALL_CLASS_SPELLS[playerClass] then
        for _,v in ipairs(ALL_CLASS_SPELLS[playerClass]) do table.insert(allAvailableSpells, v) end
    end
    
    if playerRace and ALL_CLASS_SPELLS[playerRace] then
        for _,v in ipairs(ALL_CLASS_SPELLS[playerRace]) do table.insert(allAvailableSpells, v) end
    end
    
    for _,v in ipairs(DEFAULT_ITEMS) do table.insert(allAvailableItems, v) end
    
    for _,v in ipairs(allAvailableSpells) do
        if db.enabledSpells[v.id] == nil then db.enabledSpells[v.id] = true end
        if db.enabledSpells[v.id] then spellIds[v.id] = true end
    end
    
    for _,v in ipairs(allAvailableItems) do
        if db.enabledItems[v.id] == nil then db.enabledItems[v.id] = true end
        if db.enabledItems[v.id] then itemIds[v.id] = true end
    end
end

RebuildLookups()

-- Find ALL action buttons on screen
local function GetAllButtons()
    local buttons = {}
    
    -- Standard action buttons
    for i = 1, 12 do table.insert(buttons, "ActionButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarRightButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarLeftButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarBottomRightButton" .. i) end
    for i = 1, 12 do table.insert(buttons, "MultiBarBottomLeftButton" .. i) end
    
    -- Also check for any frame with an action attribute
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

-- CUSTOM GLOW - Like Intervene with moving animation
local glows = {}

local function ShowGlow(btn)
    local name = btn:GetName()
    if not name then return end
    if glows[name] then return end
    
    -- Get button size
    local w = btn:GetWidth() or 64
    local h = btn:GetHeight() or 64
    
    -- Create glow frame
    local f = CreateFrame("Frame")
    f:SetToplevel(true)
    f:Hide()
    
    -- Create border texture (bigger than button)
    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("CENTER")
    tex:SetBlendMode("ADD")
    tex:SetWidth(w + 20)  -- 20px bigger than button
    tex:SetHeight(h + 20)
    tex:SetTexture("Interface/Buttons/UI-ActionButton-Border")
    tex:SetVertexColor(1, 0.6, 0, 1)  -- Orange glow like Intervene
    tex:SetAlpha(0.8)
    
    -- Create moving animation (like Intervene)
    local anim = f:CreateAnimationGroup()
    anim:SetLooping("REPEAT")
    
    -- Move up-right
    local move1 = anim:CreateAnimation("Translation")
    move1:SetOffset(3, 3)
    move1:SetDuration(0.5)
    move1:SetOrder(1)
    
    -- Move back to center
    local move2 = anim:CreateAnimation("Translation")
    move2:SetOffset(-3, -3)
    move2:SetDuration(0.5)
    move2:SetOrder(2)
    
    -- Scale up
    local scale1 = anim:CreateAnimation("Scale")
    scale1:SetScale(1.1, 1.1)
    scale1:SetDuration(0.5)
    scale1:SetOrder(1)
    
    -- Scale down
    local scale2 = anim:CreateAnimation("Scale")
    scale2:SetScale(1/1.1, 1/1.1)
    scale2:SetDuration(0.5)
    scale2:SetOrder(2)
    
    -- Set parent last and show
    f:SetParent(btn)
    f:ClearAllPoints()
    f:SetAllPoints(btn)
    f:Show()
    anim:Play()
    
    glows[name] = {frame=f, texture=tex, anim=anim}
end

local function HideGlow(btn)
    local name = btn:GetName()
    if not name then return end
    if glows[name] then
        glows[name].anim:Stop()
        glows[name].frame:Hide()
        glows[name] = nil
    end
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
                    local onCd = false
                    if actionType == "spell" then
                        local s = GetSpellCooldown(id)
                        if s and s > 0 then onCd = true end
                    end
                    
                    if not onCd then
                        local shouldGlow = false
                        if actionType == "item" and itemIds[id] then shouldGlow = true end
                        if actionType == "spell" and spellIds[id] then shouldGlow = true end
                        
                        if shouldGlow then
                            ShowGlow(btn)
                        end
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
    else
        if SGC_ConfigFrame then SGC_ConfigFrame:Show() end
    end
end

-- Config Frame
local frame = CreateFrame("Frame", "SGC_ConfigFrame", UIParent, "BackdropTemplate")
frame:SetSize(400, 600)
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

local enableCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", 20, -40)
enableCheck:SetChecked(db.on)
enableCheck.Text:SetText("Enable")
enableCheck:SetScript("OnClick", function() db.on = enableCheck:GetChecked(); Check() end)

local threshLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
threshLabel:SetPoint("TOPLEFT", 20, -70)
threshLabel:SetText("Health %:")

local threshSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
threshSlider:SetPoint("TOPLEFT", 100, -70)
threshSlider:SetSize(180, 20)
threshSlider:SetMinMaxValues(1, 100)
threshSlider:SetValue(db.th)
threshSlider:SetScript("OnValueChanged", function() 
    db.th = math.floor(threshSlider:GetValue()) 
    threshLabel:SetText("Health %: " .. db.th)
    Check() 
end)
threshLabel:SetPoint("LEFT", threshSlider, "RIGHT", 10, 0)

local spellLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
spellLabel:SetPoint("TOPLEFT", 20, -110)
frame.spellLabel = spellLabel

local sScroll = CreateFrame("ScrollFrame", "SGC_SSpellScroll", frame, "UIPanelScrollFrameTemplate")
sScroll:SetPoint("TOPLEFT", 20, -130)
sScroll:SetSize(360, 180)
local sChild = CreateFrame("Frame")
sChild:SetSize(360, 500)
sScroll:SetScrollChild(sChild)
frame.sChild = sChild

local itemLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
itemLabel:SetPoint("TOPLEFT", 20, -330)
frame.itemLabel = itemLabel

local iScroll = CreateFrame("ScrollFrame", "SGC_SItemScroll", frame, "UIPanelScrollFrameTemplate")
iScroll:SetPoint("TOPLEFT", 20, -350)
iScroll:SetSize(360, 180)
local iChild = CreateFrame("Frame")
iChild:SetSize(360, 500)
iScroll:SetScrollChild(iChild)
frame.iChild = iChild

local testBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
testBtn:SetPoint("BOTTOMRIGHT", -15, 15)
testBtn:SetSize(80, 25)
testBtn:SetText("Test")
testBtn:SetScript("OnClick", function() Glow(); C_Timer.NewTimer(10, ClearAll) end)

local function RefreshFrame()
    enableCheck:SetChecked(db.on)
    threshSlider:SetValue(db.th)
    threshLabel:SetText("Health %: " .. db.th)
    
    RebuildLookups()
    
    spellLabel:SetText("Spells (" .. #allAvailableSpells .. "):")
    itemLabel:SetText("Items (" .. #allAvailableItems .. "):")
    
    for _,c in ipairs({frame.sChild:GetChildren()}) do c:Hide() end
    local sy = 0
    for _,v in ipairs(allAvailableSpells) do
        local chk = CreateFrame("CheckButton", nil, frame.sChild, "InterfaceOptionsCheckButtonTemplate")
        chk:SetPoint("TOPLEFT", 0, -sy)
        chk:SetChecked(db.enabledSpells[v.id] ~= false)
        chk:SetScript("OnClick", function() db.enabledSpells[v.id] = chk:GetChecked(); RebuildLookups(); Check() end)
        
        local tex = frame.sChild:CreateTexture(nil, "ARTWORK")
        tex:SetSize(16,16)
        tex:SetPoint("LEFT", chk, "RIGHT", 2, 0)
        local icn = GetSpellTexture(v.id)
        if icn then tex:SetTexture(icn) else tex:SetColorTexture(0.5,0.5,0.5) end
        
        local txt = frame.sChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", tex, "RIGHT", 4, 0)
        txt:SetText(v.n or v.id)
        
        sy = sy + 20
    end
    frame.sChild:SetHeight(math.max(500, sy+10))
    
    for _,c in ipairs({frame.iChild:GetChildren()}) do c:Hide() end
    local iy = 0
    for _,v in ipairs(allAvailableItems) do
        local chk = CreateFrame("CheckButton", nil, frame.iChild, "InterfaceOptionsCheckButtonTemplate")
        chk:SetPoint("TOPLEFT", 0, -iy)
        chk:SetChecked(db.enabledItems[v.id] ~= false)
        chk:SetScript("OnClick", function() db.enabledItems[v.id] = chk:GetChecked(); RebuildLookups(); Check() end)
        
        local tex = frame.iChild:CreateTexture(nil, "ARTWORK")
        tex:SetSize(16,16)
        tex:SetPoint("LEFT", chk, "RIGHT", 2, 0)
        local icn = GetItemIcon(v.id)
        if icn then tex:SetTexture(icn) else tex:SetColorTexture(0.5,0.5,0.5) end
        
        local txt = frame.iChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", tex, "RIGHT", 4, 0)
        txt:SetText(v.n or v.id)
        
        iy = iy + 20
    end
    frame.iChild:SetHeight(math.max(500, iy+10))
end

frame:SetScript("OnShow", RefreshFrame)

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_,e,u)
    if e=="UNIT_HEALTH" and u=="player" then Check()
    elseif e=="PLAYER_ENTERING_WORLD" then RebuildLookups(); Check() end
end)

print("Type |cFFFFFF00/sgc|r to open config")
