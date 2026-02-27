-- SurvivalGlow Classic - FULL VERSION WITH ALL PROFESSIONS
local db = {}

-- Universal items (everyone can use)
local UNIVERSAL_ITEMS = {
    {id=6948,n="Hearthstone"},
    {id=2459,n="Swiftness Potion"},
    {id=1191,n="Bag of Marbles"},
    {id=2091,n="Magic Dust"},
    {id=3434,n="Slumber Sand"},
    {id=4366,n="Target Dummy"},
    {id=4390,n="Iron Grenade"},
    {id=13506,n="Flask of Petrification"},
    {id=5816,n="Light of Elune"},
    {id=5178,n="Noggenfogger Elixir"},
    {id=10586,n="Gnomish Mind Control Cap"},
}

-- Class spells
local ALL_CLASS_SPELLS = {
    ["HUNTER"] = {{id=5384,n="Feign Death"},{id=19263,n="Deterrence"},{id=34471,n="Misdirection"}},
    ["ROGUE"] = {{id=1856,n="Vanish"},{id=2094,n="Blind"},{id=2983,n="Sprint"},{id=26669,n="Evasion"},{id=20589,n="Escape Artist"},{id=1784,n="Stealth"}},
    ["MAGE"] = {{id=11958,n="Ice Block"},{id=1953,n="Blink"},{id=122,n="Frost Nova"},{id=45438,n="Ice Barrier"},{id=66,n="Invisibility"}},
    ["WARLOCK"] = {{id=20707,n="Soulstone"},{id=6789,n="Death Coil"},{id=18608,n="Shadow Ward"},{id=47891,n="Unending Resolve"}},
    ["PRIEST"] = {{id=47585,n="Dispersion"},{id=48173,n="Desperate Prayer"},{id=33206,n="Pain Suppression"}},
    ["DRUID"] = {{id=22812,n="Barkskin"},{id=5211,n="Bash"},{id=783,n="Travel Form"},{id=1850,n="Dash"},{id=106898,n="Stampede"}},
    ["WARRIOR"] = {{id=871,n="Shield Wall"},{id=12975,n="Last Stand"},{id=12292,n="Death Wish"},{id=18499,n="Berserker Rage"}},
    ["PALADIN"] = {{id=642,n="Divine Shield"},{id=1022,n="Blessing of Protection"},{id=19753,n="Divine Intervention"},{id=498,n="Divine Protection"}},
    ["SHAMAN"] = {{id=2645,n="Ghost Wolf"},{id=546,n="Water Walking"},{id=57960,n="Nature's Swiftness"},{id=30823,n="Shamanistic Rage"}},
    ["DEATHKNIGHT"] = {{id=49028,n="Icebound Fortitude"},{id=48743,n="Death Pact"},{id=51052,n="Anti-Magic Zone"}},
    ["MONK"] = {{id=115203,n="Fortifying Brew"},{id=116705,n="Spear Hand Strike"},{id=122783,n="Diffuse Magic"}},
    ["EVOKER"] = {{id=360823,n="Obsidian Scales"},{id=370665,n="Spontaneous Appendage"}},
}

-- Racial abilities
local RACIAL_SPELLS = {
    ["GNOME"] = {{id=20589,n="Escape Artist"},{id=20592,n="Engineering Specialist"}},
    ["DWARF"] = {{id=20594,n="Stoneform"},{id=20596,n="Might of the Mountain"}},
    ["NIGHTELF"] = {{id=20580,n="Shadowmeld"},{id=58984,n="Shadowmeld (Racial)"}},
    ["UNDEAD"] = {{id=7744,n="Will of the Forsaken"},{id=20577,n="Cannibalize"}},
    ["ORC"] = {{id=20572,n="Blood Fury"},{id=33702,n="Blood Fury (Phys)"}},
    ["TAUREN"] = {{id=20549,n="War Stomp"},{id=59752,n="Endurance"}},
    ["TROLL"] = {{id=26297,n="Berserking"},{id=20555,n="Regeneration"}},
    ["HUMAN"] = {{id=59752,n="Every Man for Himself"},{id=54400,n="Diplomacy"}},
    ["BLOODELF"] = {{id=28730,n="Arcane Torrent"},{id=69179,n="Heroism"}},
    ["DRAENEI"] = {{id=28880,n="Gift of the Naaru"},{id=6562,n="Heroic Presence"}},
}

-- Profession items (164=Engineering, 171=Alchemy, 129=First Aid, 185=Cooking)
local PROF_ITEMS = {
    [164] = {  -- Engineering
        {id=10720,n="Gnomish Rocket Boots"},
        {id=10721,n="Goblin Rocket Boots"},
        {id=23826,n="Gnomish Rocket Boots"},
        {id=11850,n="Gnomish Death Ray"},
        {id=12561,n="Gnomish Shrink Ray"},
        {id=10646,n="Goblin Sapper Charge"},
        {id=4382,n="Goblin Rocket Fuel"},
        {id=15137,n="Goblin Rocket Helmet"},
        {id=40566,n="Gnomish Power Trip"},
        {id=40567,n="Gnomish Poultryizer"}},
    [171] = {  -- Alchemy
        {id=5634,n="Healthstone"},
        {id=13512,n="Greater Healthstone"},
        {id=13511,n="Major Healthstone"},
        {id=22116,n="Major Rejuvenation Potion"},
        {id=17200,n="Greater Stoneshield Potion"},
        {id=11371,n="Shadow Protection Potion"},
        {id=11396,n="Fire Protection Potion"},
        {id=11348,n="Frost Protection Potion"},
        {id=11284,n="Nature Protection Potion"},
        {id=22839,n="Major Nature Protection Potion"},
        {id=28558,n="Superior Healing Potion"},
        {id=39132,n="Runic Healing Potion"},
        {id=33448,n="Mad Alchemist's Potion"},
        {id=53748,n="Endless Healing Potion"},
        {id=53749,n="Endless Mana Potion"},
        {id=40093,n="Potion of Speed"},
        {id=40087,n="Potion of Might"}},
    [129] = {  -- First Aid
        {id=12585,n="Heavy Runecloth Bandage"},
        {id=12584,n="Runecloth Bandage"},
        {id=12583,n="Silk Bandage"},
        {id=12582,n="Wool Bandage"},
        {id=12581,n="Linen Bandage"}},
    [185] = {  -- Cooking
        {id=42932,n="Spicy Hot Talbuk"},
        {id=42931,n="Seared Spotted Wing"},
        {id=25557,n="Warrior's Feast"},
        {id=13813,n="Sagefish Delight"},
        {id=13146,n="Thick Wolf Meat"},
        {id=17222,n="Clam Chowder"},
        {id=17224,n="Kibler's Bits"}},
    [165] = {  -- Leatherworking
        {id=37750,n="Jormungar Hide"},
        {id=37700,n="Netherweb Spider Silk"}},
    [197] = {  -- Tailoring
        {id=33430,n="Primal Mooncloth"},
        {id=33439,n="Shadowcloth"}},
    [333] = {  -- Enchanting
        {id=20753,n="Scroll of Recall"},
        {id=20752,n="Scroll of Recall II"},
        {id=20751,n="Scroll of Recall III"},
        {id=27867,n="Void Sphere"}},
    [755] = {  -- Jewelcrafting
        {id=32449,n="Mercurial Alchemist Stone"},
        {id=35760,n="Alchemist's Stone"}},
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
local playerProfs = {}
local allAvailableSpells = {}
local allAvailableItems = {}
local itemIds = {}
local spellIds = {}

local function GetPlayerProfessions()
    playerProfs = {}
    local prof1, prof2 = GetProfessions()
    if prof1 then table.insert(playerProfs, prof1) end
    if prof2 then table.insert(playerProfs, prof2) end
end

local function RebuildLookups()
    GetPlayerProfessions()
    
    wipe(itemIds)
    wipe(spellIds)
    wipe(allAvailableSpells)
    wipe(allAvailableItems)
    
    -- Add universal items (everyone has access)
    for _,v in ipairs(UNIVERSAL_ITEMS) do
        table.insert(allAvailableItems, v)
    end
    
    -- Add profession items based on player's professions
    for _, prof in ipairs(playerProfs) do
        if PROF_ITEMS[prof] then
            for _,v in ipairs(PROF_ITEMS[prof]) do
                table.insert(allAvailableItems, v)
            end
        end
    end
    
    -- Add class spells
    if playerClass and ALL_CLASS_SPELLS[playerClass] then
        for _,v in ipairs(ALL_CLASS_SPELLS[playerClass]) do table.insert(allAvailableSpells, v) end
    end
    
    -- Add racial spells
    if playerRace and RACIAL_SPELLS[playerRace] then
        for _,v in ipairs(RACIAL_SPELLS[playerRace]) do table.insert(allAvailableSpells, v) end
    end
    
    -- Build enabled lookups
    for _,v in ipairs(allAvailableSpells) do
        if db.enabledSpells[v.id] == nil then db.enabledSpells[v.id] = true end
        if db.enabledSpells[v.id] then spellIds[v.id] = true end
    end
    
    for _,v in ipairs(allAvailableItems) do
        if db.enabledItems[v.id] == nil then db.enabledItems[v.id] = true end
        if db.enabledItems[v.id] then itemIds[v.id] = true end
    end
    
    print("Professions:", #playerProfs, "Spells:", #allAvailableSpells, "Items:", #allAvailableItems)
end

RebuildLookups()

-- Find ALL action buttons on screen
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

-- Use WoW's built-in glow (same as Intervene uses)
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

-- Check if ability is on cooldown
local function IsOnCooldown(actionType, id)
    if actionType == "spell" then
        local start, duration = GetSpellCooldown(id)
        if start and start > 0 and duration and duration > 0 then
            return true
        end
    elseif actionType == "item" then
        local start, duration = GetItemCooldown(id)
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
                    if not IsOnCooldown(actionType, id) then
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
frame:SetSize(420, 650)
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

local profLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
profLabel:SetPoint("TOPLEFT", 20, -35)
frame.profLabel = profLabel

local enableCheck = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", 20, -55)
enableCheck:SetChecked(db.on)
enableCheck.Text:SetText("Enable")
enableCheck:SetScript("OnClick", function() db.on = enableCheck:GetChecked(); Check() end)

local threshLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
threshLabel:SetPoint("TOPLEFT", 20, -85)
threshLabel:SetText("Health %:")

local threshSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
threshSlider:SetPoint("TOPLEFT", 100, -85)
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
spellLabel:SetPoint("TOPLEFT", 20, -125)
frame.spellLabel = spellLabel

local sScroll = CreateFrame("ScrollFrame", "SGC_SSpellScroll", frame, "UIPanelScrollFrameTemplate")
sScroll:SetPoint("TOPLEFT", 20, -145)
sScroll:SetSize(380, 180)
local sChild = CreateFrame("Frame")
sChild:SetSize(380, 600)
sScroll:SetScrollChild(sChild)
frame.sChild = sChild

local itemLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
itemLabel:SetPoint("TOPLEFT", 20, -340)
frame.itemLabel = itemLabel

local iScroll = CreateFrame("ScrollFrame", "SGC_SItemScroll", frame, "UIPanelScrollFrameTemplate")
iScroll:SetPoint("TOPLEFT", 20, -360)
iScroll:SetSize(380, 180)
local iChild = CreateFrame("Frame")
iChild:SetSize(380, 800)
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
    
    local profsText = "Prof: "
    if #playerProfs == 0 then profsText = profsText .. "None"
    else
        local pname = {[164]="Eng",[171]="Alch",[129]="1stAid",[185]="Cook",[165]="LW",[197]="Tail",[333]="Ench",[755]="JC"}
        for i,p in ipairs(playerProfs) do
            profsText = profsText .. (pname[p] or tostring(p))
            if i < #playerProfs then profsText = profsText .. ", " end
        end
    end
    profLabel:SetText(profsText)
    
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
    frame.sChild:SetHeight(math.max(600, sy+10))
    
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
    frame.iChild:SetHeight(math.max(800, iy+10))
end

frame:SetScript("OnShow", RefreshFrame)

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("SKILL_LINES_CHANGED")
f:SetScript("OnEvent", function(_,e,u)
    if e=="UNIT_HEALTH" and u=="player" then Check()
    elseif e=="PLAYER_ENTERING_WORLD" or e=="SKILL_LINES_CHANGED" then 
        RebuildLookups() 
        Check() 
    end
end)

print("Type |cFFFFFF00/sgc|r to open config")
