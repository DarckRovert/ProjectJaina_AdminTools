--=========================================================================
-- Admin Tools - quick GM command panel for WOTLK 3.3.5a (TrinityCore / SPP)
--
-- Commands are sent as chat text starting with "." exactly as if you typed
-- them.  On TrinityCore the server intercepts these before they are spoken,
-- so nothing is broadcast as long as the account has GM access and the
-- command is valid.  If a command is rejected it will appear in /say.
--
-- Slash: /admin  (or /adt)   - toggles the window
--        /admin <command>    - runs a single command (leading "." optional)
--
-- Tweaking: every button is just { "Label", ".command" }.  Edit the tables
-- below to add/remove/reorder buttons, or use the Custom tab in-game.
--=========================================================================

local ADDON = ...
local floor, ceil = math.floor, math.ceil

-- Largest normal (non-profession) bag in WotLK 3.3.5a = 22 slots.
-- Glacial Bag, itemID 41600.  Alternate 22-slotter: Gigantique Bag 34845.
local MAX_BAG_ID = 41600

---------------------------------------------------------------------------
-- Core: run a command
---------------------------------------------------------------------------
local function RunCmd(cmd)
	if type(cmd) ~= "string" then return end
	cmd = strtrim(cmd)
	if cmd == "" then return end
	if cmd:sub(1, 1) ~= "." then cmd = "." .. cmd end
	if #cmd > 255 then cmd = cmd:sub(1, 255) end
	SendChatMessage(cmd, "SAY")
	if not AdminToolsDB or AdminToolsDB.echo ~= false then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD700[WoW Perú Admin]|r " .. cmd)
	end
end

local function ConfirmCmd(cmd)
	local d = StaticPopup_Show("ADMINTOOLS_CONFIRM", cmd)
	if d then d.data = cmd end
end

StaticPopupDialogs["ADMINTOOLS_CONFIRM"] = {
	text = "Run this command?\n\n|cffffd100%s|r",
	button1 = YES, button2 = NO,
	OnAccept = function(self, data) RunCmd(data) end,
	timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

StaticPopupDialogs["ADMINTOOLS_ENEMYCITY"] = {
	text = "That is a |cffff2020%s|r capital.\nEnemy guards will attack you on arrival.\n\nTeleport anyway?",
	button1 = YES, button2 = NO,
	OnAccept = function(self, data) RunCmd(data) end,
	timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

---------------------------------------------------------------------------
-- Widget helpers
---------------------------------------------------------------------------
local BTN_W, BTN_H, PAD = 122, 22, 6

local function MakeButton(parent, text, w, action)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(w or BTN_W, BTN_H)
	b:SetText(text)
	b:SetScript("OnClick", function()
		if type(action) == "function" then action() else RunCmd(action) end
	end)
	return b
end

local function MakeEdit(parent, w)
	local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	e:SetSize(w or 160, 20)
	e:SetAutoFocus(false)
	e:SetScript("OnEscapePressed", e.ClearFocus)
	e:SetScript("OnEnterPressed", e.ClearFocus)
	return e
end

local function MakeLabel(parent, text, template)
	local fs = parent:CreateFontString(nil, "ARTWORK", template or "GameFontNormalSmall")
	fs:SetText(text)
	return fs
end

-- lay out a list of {label, cmd} buttons in a 3-wide grid; returns next Y
local function FlowButtons(page, defs, startY)
	local cols = 3
	for i, d in ipairs(defs) do
		local col = (i - 1) % cols
		local row = floor((i - 1) / cols)
		local b = MakeButton(page, d[1], BTN_W, d[2])
		b:SetPoint("TOPLEFT", page, "TOPLEFT", 4 + col * (BTN_W + PAD), startY - row * (BTN_H + PAD))
	end
	return startY - ceil(#defs / cols) * (BTN_H + PAD) - PAD
end

-- label + one editbox + Go button; builder(text) -> command string
local function FormRow(page, y, labelText, builder, width)
	local lbl = MakeLabel(page, labelText)
	lbl:SetPoint("TOPLEFT", page, "TOPLEFT", 6, y - 5)
	local e = MakeEdit(page, width or 170)
	e:SetPoint("TOPLEFT", page, "TOPLEFT", 122, y)
	local function fire()
		local t = strtrim(e:GetText() or "")
		if t ~= "" then RunCmd(builder(t)) end
	end
	local go = MakeButton(page, "Go", 40, fire)
	go:SetPoint("LEFT", e, "RIGHT", 6, 0)
	e:SetScript("OnEnterPressed", function(self) fire(); self:ClearFocus() end)
	return y - 26, e
end

-- label + two editboxes + Go button; builder(a, b) -> command string
local function FormRow2(page, y, labelText, builder)
	local lbl = MakeLabel(page, labelText)
	lbl:SetPoint("TOPLEFT", page, "TOPLEFT", 6, y - 5)
	local e1 = MakeEdit(page, 90)
	e1:SetPoint("TOPLEFT", page, "TOPLEFT", 122, y)
	local e2 = MakeEdit(page, 60)
	e2:SetPoint("LEFT", e1, "RIGHT", 6, 0)
	local function fire()
		local a = strtrim(e1:GetText() or "")
		local b = strtrim(e2:GetText() or "")
		if a ~= "" then RunCmd(builder(a, b)) end
	end
	local go = MakeButton(page, "Go", 40, fire)
	go:SetPoint("LEFT", e2, "RIGHT", 6, 0)
	e1:SetScript("OnEnterPressed", function() fire() end)
	e2:SetScript("OnEnterPressed", function(self) fire(); self:ClearFocus() end)
	return y - 26
end

-- teleport button that warns before dropping you in an enemy capital
local function MakeTeleButton(parent, label, teleName, cityFaction)
	return MakeButton(parent, label, BTN_W, function()
		local pf = UnitFactionGroup("player")
		if cityFaction and cityFaction ~= "Neutral" and pf and cityFaction ~= pf then
			local d = StaticPopup_Show("ADMINTOOLS_ENEMYCITY", cityFaction)
			if d then d.data = ".tele " .. teleName end
		else
			RunCmd(".tele " .. teleName)
		end
	end)
end

-- header + grid of {label, teleName, faction} buttons; returns next Y
local function TeleSection(page, y, header, list)
	local h = MakeLabel(page, header, "GameFontNormal")
	h:SetPoint("TOPLEFT", page, "TOPLEFT", 6, y)
	y = y - 16
	local cols = 3
	for i, e in ipairs(list) do
		local col = (i - 1) % cols
		local row = floor((i - 1) / cols)
		local b = MakeTeleButton(page, e[1], e[2], e[3])
		b:SetPoint("TOPLEFT", page, "TOPLEFT", 4 + col * (BTN_W + PAD), y - row * (BTN_H + PAD))
	end
	return y - ceil(#list / cols) * (BTN_H + PAD) - PAD - 2
end

---------------------------------------------------------------------------
-- Main frame
---------------------------------------------------------------------------
local f = CreateFrame("Frame", "AdminToolsFrame", UIParent)
f:SetSize(550, 484)
f:SetPoint("CENTER")
f:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
f:SetToplevel(true)
f:SetClampedToScreen(true)
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	local p, _, rp, x, y = self:GetPoint()
	if AdminToolsDB then AdminToolsDB.pos = { p, rp, x, y } end
end)
f:SetScript("OnMouseDown", function(self) self:Raise() end)
f:Hide()
tinsert(UISpecialFrames, "AdminToolsFrame")  -- ESC closes

local title = MakeLabel(f, "|cFFFFD700WoW Perú|r |cFF00FFCCAdmin Tools|r |cFF888888v2.0.1|r", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -16)

local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -8, -8)

-- bottom command bar (always visible).  Strata bumped to HIGH so dense tab
-- content (e.g. Tele/Travel) can never visually overlap the typed text.
local cmdLabel = MakeLabel(f, "Command:")
cmdLabel:SetPoint("BOTTOMLEFT", 22, 22)
local cmdBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
cmdBox:SetSize(300, 20)
cmdBox:SetPoint("LEFT", cmdLabel, "RIGHT", 10, 0)
cmdBox:SetAutoFocus(false)
cmdBox:SetFrameStrata("HIGH")
cmdBox:SetScript("OnEscapePressed", cmdBox.ClearFocus)
cmdBox:SetScript("OnEnterPressed", function(self)
	RunCmd(self:GetText()); self:SetText(""); self:ClearFocus()
end)
local runBtn = MakeButton(f, "Run", 44, function()
	RunCmd(cmdBox:GetText()); cmdBox:SetText("")
end)
runBtn:SetPoint("LEFT", cmdBox, "RIGHT", 8, 0)
runBtn:SetFrameStrata("HIGH")

---------------------------------------------------------------------------
-- Tabs / pages
---------------------------------------------------------------------------
local TABS = { "Tele", "Travel", "Self", "Char", "Party", "Summon", "Server", "Custom" }
local pages, tabButtons = {}, {}

local function ShowPage(name)
	for n, p in pairs(pages) do
		if n == name then p:Show() else p:Hide() end
	end
	for n, b in pairs(tabButtons) do
		if n == name then b:LockHighlight() else b:UnlockHighlight() end
	end
	if AdminToolsDB then AdminToolsDB.tab = name end
end

for i, name in ipairs(TABS) do
	local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	b:SetSize(62, 22)
	b:SetText(name)
	b:SetPoint("TOPLEFT", f, "TOPLEFT", 14 + (i - 1) * 64, -44)
	b:SetScript("OnClick", function() ShowPage(name) end)
	tabButtons[name] = b

	local p = CreateFrame("Frame", nil, f)
	p:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -74)
	p:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -18, 50)
	p:Hide()
	pages[name] = p
end

---------------------------------------------------------------------------
-- Mount menu (used by the Char tab button)
---------------------------------------------------------------------------
-- Each leaf is { "Name", ".learn <spellID>" }.  A wrong ID just prints a
-- harmless "spell does not exist" - fix or add your own on the Custom tab.
local MOUNTS = {
	{ "Riding Skills", {
		{ "Apprentice Riding (60% ground)",  ".learn 33388" },
		{ "Journeyman Riding (100% ground)", ".learn 33391" },
		{ "Expert Riding (150% flying)",     ".learn 34090" },
		{ "Artisan Riding (280% flying)",    ".learn 34091" },
		{ "Cold Weather Flying (Northrend)", ".learn 54197" },
	} },
	{ "Flying - Basic 150%", {
		{ "Golden Gryphon",   ".learn 32235" },
		{ "Ebon Gryphon",     ".learn 32239" },
		{ "Snowy Gryphon",    ".learn 32240" },
		{ "Tawny Wind Rider", ".learn 32243" },
		{ "Blue Wind Rider",  ".learn 32244" },
		{ "Green Wind Rider", ".learn 32245" },
	} },
	{ "Flying - Epic 280%", {
		{ "Swift Red Gryphon",      ".learn 32290" },
		{ "Swift Blue Gryphon",     ".learn 32242" },
		{ "Swift Green Gryphon",    ".learn 32292" },
		{ "Swift Purple Gryphon",   ".learn 32289" },
		{ "Swift Green Wind Rider", ".learn 32295" },
		{ "Swift Yellow Wind Rider",".learn 32297" },
		{ "Swift Purple Wind Rider",".learn 32296" },
		{ "Swift Flying Machine",   ".learn 44153" },
	} },
	{ "Drakes / Proto-Drakes", {
		{ "Violet Proto-Drake",     ".learn 43671" },
		{ "Red Proto-Drake",        ".learn 59961" },
		{ "Blue Proto-Drake",       ".learn 59996" },
		{ "Black Proto-Drake",      ".learn 59976" },
		{ "Time-Lost Proto-Drake",  ".learn 60002" },
		{ "Plagued Proto-Drake",    ".learn 60021" },
		{ "Albino Drake",           ".learn 60025" },
		{ "Bronze Drake",           ".learn 59567" },
		{ "Azure Drake",            ".learn 59568" },
		{ "Blue Drake",             ".learn 59569" },
		{ "Twilight Drake",         ".learn 61230" },
	} },
	{ "Netherwing Drakes", {
		{ "Veridian Netherwing Drake", ".learn 41514" },
		{ "Green Netherwing Drake",    ".learn 41515" },
		{ "Purple Netherwing Drake",   ".learn 41516" },
		{ "Cobalt Netherwing Drake",   ".learn 41517" },
		{ "Onyx Netherwing Drake",     ".learn 41518" },
		{ "Azure Netherwing Drake",    ".learn 41519" },
	} },
	{ "Ground - Special / Fun", {
		{ "Big Blizzard Bear",          ".learn 58983" },
		{ "Swift Zhevra",               ".learn 37719" },
		{ "Mekgineer's Chopper",        ".learn 60421" },
		{ "Mechano-hog",                ".learn 60424" },
		{ "Traveler's Tundra Mammoth (A)", ".learn 61425" },
		{ "Traveler's Tundra Mammoth (H)", ".learn 61447" },
		{ "Swift Brewfest Ram",         ".learn 43900" },
		{ "Great Brewfest Kodo",        ".learn 49379" },
		{ "Headless Horseman's Mount",  ".learn 48025" },
		{ "Fiery Warhorse",             ".learn 36702" },
		{ "Reins of the Raven Lord",    ".learn 41252" },
		{ "Swift White Hawkstrider",    ".learn 46628" },
		{ "X-51 Nether-Rocket X-TREME", ".learn 46199" },
		{ "Argent Hippogryph",          ".learn 63844" },
		{ "Quel'dorei Steed",           ".learn 63643" },
	} },
	{ "Class Mounts", {
		{ "Paladin - Warhorse",              ".learn 13819" },
		{ "Paladin - Charger",               ".learn 23214" },
		{ "Warlock - Felsteed",              ".learn 5784" },
		{ "Warlock - Dreadsteed",            ".learn 23161" },
		{ "Death Knight - Acherus Deathcharger", ".learn 48778" },
		{ "Death Knight - Winged Steed",     ".learn 54729" },
	} },
}

---------------------------------------------------------------------------
-- Generic nested dropdown: leaves { "Text", ".cmd" }, branches { "Text", { ... } }
-- Returns an opener function that pops the menu at the cursor.
---------------------------------------------------------------------------
local function BuildMenu(globalName, dataTable)
	local menu = CreateFrame("Frame", globalName, f, "UIDropDownMenuTemplate")
	local function init(_, level)
		if not level then return end
		local data = (level == 1) and dataTable or UIDROPDOWNMENU_MENU_VALUE
		if type(data) ~= "table" then return end
		for _, entry in ipairs(data) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = entry[1]
			info.notCheckable = true
			if type(entry[2]) == "table" then
				info.hasArrow = true
				info.value = entry[2]
			else
				local cmd = entry[2]
				info.func = function() RunCmd(cmd); CloseDropDownMenus() end
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(menu, init, "MENU")
	return function() ToggleDropDownMenu(1, nil, menu, "cursor", 0, 0) end
end

-- 5-man dungeons, grouped by expansion, ordered by level.  Teleports land
-- just outside the entrance.  Most are ".tele <game_tele name>"; entries that
-- TrinityCore's stock game_tele lacks use raw ".go xyz X Y Z map" coordinates
-- instead (works on any core).  If a ".tele" one fails, use the Tele tab >
-- "Lookup tele" box to find your server's name and edit it here.
local DUNGEONS = {
	{ "Classic", {
		{ "Ragefire Chasm (13-18)",     ".tele RagefireChasm" },
		{ "Wailing Caverns (15-25)",    ".tele TheWailingCaverns" },
		{ "The Deadmines (15-25)",      ".tele TheDeadmines" },
		{ "Shadowfang Keep (16-26)",    ".tele ShadowfangKeep" },
		{ "Blackfathom Deeps (18-28)",  ".tele BlackfathomDeeps" },
		{ "The Stockade (22-30)",       ".go xyz -8779.9 834.35 94.68 0" },
		{ "Gnomeregan (24-34)",         ".tele Gnomeregan" },
		{ "Razorfen Kraul (25-35)",     ".tele RazorfenKraul" },
		{ "Scarlet Monastery (28-45)",  ".tele ScarletMonastery" },
		{ "Razorfen Downs (35-45)",     ".tele RazorfenDowns" },
		{ "Uldaman (35-45)",            ".tele Uldaman" },
		{ "Zul'Farrak (42-52)",         ".tele ZulFarrak" },
		{ "Maraudon (45-55)",           ".tele Maraudon" },
		{ "Sunken Temple (50-60)",      ".tele TheSunkenTemple" },
		{ "Blackrock Depths (52-60)",   ".tele BlackrockDepths" },
		{ "LBRS / UBRS (55-60)",        ".tele BlackrockSpire" },
		{ "Dire Maul West (55-60)",     ".tele DireMaulWest" },
		{ "Dire Maul North (56-60)",    ".tele DireMaulNorth" },
		{ "Dire Maul East (58-60)",     ".tele DireMaulEast" },
		{ "Scholomance (58-60)",        ".tele Scholomance" },
		{ "Stratholme (58-60)",         ".tele Stratholme" },
	} },
	{ "Burning Crusade", {
		{ "Hellfire Ramparts (60-62)",  ".tele HellfireRamparts" },
		{ "The Blood Furnace (61-64)",  ".tele TheBloodFurnace" },
		{ "The Slave Pens (62-64)",     ".tele TheSlavePens" },
		{ "The Underbog (63-65)",       ".tele CoilfangReservoir" },
		{ "Mana-Tombs (64-66)",         ".tele ManaTombs" },
		{ "Auchenai Crypts (65-67)",    ".tele AuchenaiCrypts" },
		{ "Old Hillsbrad (66-68)",      ".tele OldHillsbradFoothills" },
		{ "Sethekk Halls (67-69)",      ".tele SethekkHalls" },
		{ "The Steamvault (68-70)",     ".tele TheSteamvault" },
		{ "Shadow Labyrinth (70)",      ".tele ShadowLabyrinth" },
		{ "The Black Morass (70)",      ".tele TheBlackMorass" },
		{ "The Mechanar (70)",          ".tele TheMechanar" },
		{ "The Botanica (70)",          ".tele TheBotanica" },
		{ "The Arcatraz (70)",          ".tele TheArcatraz" },
		{ "The Shattered Halls (70)",   ".tele TheShatteredHalls" },
		{ "Magisters' Terrace (70)",    ".tele MagistersTerrace" },
	} },
	{ "Wrath of the Lich King", {
		{ "Utgarde Keep (70-72)",       ".tele UtgardeKeep" },
		{ "The Nexus (71-73)",          ".tele TheNexus" },
		{ "Azjol-Nerub (72-74)",        ".tele AzjolNerub" },
		{ "Ahn'kahet: Old Kingdom (73-75)", ".go xyz 3643.31 2036.51 1.79 571" },
		{ "Drak'Tharon Keep (74-76)",   ".tele DrakTharonKeep" },
		{ "The Violet Hold (75-77)",    ".tele TheVioletHold" },
		{ "Gundrak (76-78)",            ".tele Gundrak" },
		{ "Halls of Stone (77-79)",     ".go xyz 8921.91 -993.5 1039.41 571" },
		{ "Halls of Lightning (78-80)", ".go xyz 9182.92 -1384.82 1110.21 571" },
		{ "Utgarde Pinnacle (78-80)",   ".tele UtgardePinnacle" },
		{ "The Oculus (78-80)",         ".go xyz 3879.96 6984.62 106.31 571" },
		{ "Culling of Stratholme (78-80)", ".go xyz -8750.76 -4442.2 -199.26 1" },
		{ "Trial of the Champion (80)", ".tele TrialOfTheChampion" },
		{ "The Forge of Souls (80)",    ".go xyz 5666.25 2009.2 798.04 571" },
		{ "Pit of Saron (80)",          ".go xyz 5598.74 2015.85 798.04 571" },
		{ "Halls of Reflection (80)",   ".go xyz 5630.44 1994.01 798.06 571" },
	} },
}

local RAIDS = {
	{ "Classic", {
		{ "Molten Core (60)",           ".tele MoltenCore" },
		{ "Blackwing Lair (60)",        ".go xyz -7396.4 -1070.18 589.39 469" },
		{ "Zul'Gurub (60)",             ".tele ZulGurub" },
		{ "Ruins of Ahn'Qiraj (AQ20)",  ".tele AQ20" },
		{ "Temple of Ahn'Qiraj (AQ40)", ".tele AQ40" },
	} },
	{ "Burning Crusade", {
		{ "Karazhan (70)",              ".tele Karazhan" },
		{ "Gruul's Lair (70)",          ".tele GruulsLair" },
		{ "Magtheridon's Lair (70)",    ".tele MagtheridonsLair" },
		{ "Serpentshrine Cavern (70)",  ".tele SerpentshrineCavern" },
		{ "Tempest Keep: The Eye (70)", ".tele TempestKeep" },
		{ "Hyjal Summit (70)",          ".tele HyjalSummit" },
		{ "Black Temple (70)",          ".tele BlackTemple" },
		{ "Zul'Aman (70)",              ".tele ZulAman" },
		{ "Sunwell Plateau (70)",       ".tele SunwellPlateau" },
	} },
	{ "Wrath of the Lich King", {
		{ "Naxxramas (80)",             ".go xyz 3668.72 -1262.46 243.62 571" },
		{ "The Obsidian Sanctum (80)",  ".tele TheObsidianSanctum" },
		{ "The Eye of Eternity (80)",   ".go xyz 3859.44 6989.85 152.04 571" },
		{ "Ulduar (80)",                ".tele Ulduar" },
		{ "Trial of the Crusader (80)", ".tele TrialOfTheCrusader" },
		{ "Onyxia's Lair (80)",         ".tele OnyxiasLair" },
		{ "Vault of Archavon (80)",     ".tele VaultOfArchavon" },
		{ "Icecrown Citadel (80)",      ".go xyz 5873.82 2110.98 636.01 571" },
		{ "The Ruby Sanctum (80)",      ".tele TheRubySanctum" },
	} },
}

-- One decent grinding / questing hub per ~5 levels, 1-80, faction-appropriate.
local GRIND_A = {
	{ "1-6   Northshire (Elwynn)",        ".tele NorthshireValley" },
	{ "6-10  Goldshire (Elwynn)",         ".tele Goldshire" },
	{ "10-15 Sentinel Hill (Westfall)",   ".tele SentinelHill" },
	{ "15-20 Lakeshire (Redridge)",       ".tele Lakeshire" },
	{ "20-25 Darkshire (Duskwood)",       ".tele Darkshire" },
	{ "25-30 Astranaar (Ashenvale)",      ".tele Astranaar" },
	{ "30-35 Refuge Pointe (Arathi)",     ".tele RefugePointe" },
	{ "35-40 Rebel Camp (Stranglethorn)", ".tele RebelCamp" },
	{ "40-45 Theramore (Dustwallow)",     ".tele TheramoreIsle" },
	{ "45-50 Gadgetzan (Tanaris)",        ".tele Gadgetzan" },
	{ "50-54 Marshal's Refuge (Un'Goro)", ".tele MarshalsRefuge" },
	{ "53-58 Chillwind Camp (W. Plague)", ".tele ChillwindCamp" },
	{ "55-60 Light's Hope (E. Plague)",   ".tele LightsHopeChapel" },
	{ "58-63 Honor Hold (Hellfire)",      ".tele HonorHold" },
	{ "62-66 Telredor (Zangarmarsh)",     ".tele Telredor" },
	{ "64-67 Telaar (Nagrand)",           ".tele Telaar" },
	{ "67-70 Sylvanaar (Blade's Edge)",   ".tele Sylvanaar" },
	{ "68-70 Area 52 (Netherstorm)",      ".tele Area52" },
	{ "70-72 Valiance Keep (Borean Tundra)", ".tele ValianceKeep" },
	{ "71-73 Valgarde (Howling Fjord)",   ".tele Valgarde" },
	{ "73-75 Wintergarde Keep (Dragonblight)", ".tele WintergardeKeep" },
	{ "74-77 Amberpine Lodge (Grizzly Hills)", ".tele AmberpineLodge" },
	{ "76-78 Ebon Watch (Zul'Drak)",      ".tele EbonWatch" },
	{ "77-80 Nesingwary Camp (Sholazar)", ".tele NesingwaryBaseCamp" },
	{ "78-80 K3 (Storm Peaks)",           ".tele K3" },
	{ "79-80 The Argent Vanguard (Icecrown)", ".tele TheArgentVanguard" },
}
local GRIND_H = {
	{ "1-6   Valley of Trials (Durotar)", ".tele ValleyOfTrials" },
	{ "6-10  Razor Hill (Durotar)",       ".tele RazorHill" },
	{ "10-15 The Crossroads (Barrens)",   ".tele TheCrossroads" },
	{ "15-20 The Sepulcher (Silverpine)", ".tele TheSepulcher" },
	{ "20-25 Splintertree Post (Ashenvale)", ".tele SplintertreePost" },
	{ "25-30 Tarren Mill (Hillsbrad)",    ".tele TarrenMill" },
	{ "30-35 Hammerfall (Arathi)",        ".tele Hammerfall" },
	{ "35-40 Grom'gol (Stranglethorn)",   ".tele GromgolBaseCamp" },
	{ "40-45 Brackenwall (Dustwallow)",   ".tele BrackenwallVillage" },
	{ "45-50 Gadgetzan (Tanaris)",        ".tele Gadgetzan" },
	{ "50-54 Bloodvenom Post (Felwood)",  ".tele BloodvenomPost" },
	{ "52-56 Marshal's Refuge (Un'Goro)", ".tele MarshalsRefuge" },
	{ "55-58 Light's Hope (E. Plague)",   ".tele LightsHopeChapel" },
	{ "58-63 Thrallmar (Hellfire)",       ".tele Thrallmar" },
	{ "62-66 Zabra'jin (Zangarmarsh)",    ".tele Zabrajin" },
	{ "64-67 Garadar (Nagrand)",          ".tele Garadar" },
	{ "67-70 Thunderlord Stronghold (Blade's Edge)", ".tele ThunderlordStronghold" },
	{ "68-70 Area 52 (Netherstorm)",      ".tele Area52" },
	{ "70-72 Warsong Hold (Borean Tundra)", ".tele WarsongHold" },
	{ "71-73 Vengeance Landing (Howling Fjord)", ".tele VengeanceLanding" },
	{ "73-75 Agmar's Hammer (Dragonblight)", ".tele AgmarsHammer" },
	{ "74-77 Conquest Hold (Grizzly Hills)", ".tele ConquestHold" },
	{ "76-78 Light's Breach (Zul'Drak)",  ".tele LightsBreach" },
	{ "77-80 Nesingwary Camp (Sholazar)", ".tele NesingwaryBaseCamp" },
	{ "78-80 Camp Tunka'lo (Storm Peaks)", ".tele CampTunkaLo" },
	{ "79-80 The Argent Vanguard (Icecrown)", ".tele TheArgentVanguard" },
}

-- Class trainers for the Summon tab: real Blizzard trainer NPCs, faction-
-- matched (verified against each NPC's actual faction template ID in the
-- world database) so a Horde or Alliance character can use them.  Death
-- Knight has no stock spawnable trainer (DK training is special-cased at
-- Ebon Hold), so it isn't listed here.
local TRAINERS = {
	{ "Alliance", {
		{ "Mage",    ".npc add temp 198" },
		{ "Priest",  ".npc add temp 375" },
		{ "Warlock", ".npc add temp 459" },
		{ "Hunter",  ".npc add temp 895" },
		{ "Warrior", ".npc add temp 911" },
		{ "Rogue",   ".npc add temp 915" },
		{ "Paladin", ".npc add temp 925" },
		{ "Shaman",  ".npc add temp 17204" },
		{ "Druid",   ".npc add temp 5504" },
	} },
	{ "Horde", {
		{ "Mage",    ".npc add temp 5883" },
		{ "Priest",  ".npc add temp 6014" },
		{ "Warlock", ".npc add temp 988" },
		{ "Hunter",  ".npc add temp 987" },
		{ "Warrior", ".npc add temp 985" },
		{ "Rogue",   ".npc add temp 3328" },
		{ "Paladin", ".npc add temp 16680" },
		{ "Shaman",  ".npc add temp 986" },
		{ "Druid",   ".npc add temp 3033" },
	} },
}

local openMounts   = BuildMenu("AdminToolsMountMenu",   MOUNTS)
local openDungeons = BuildMenu("AdminToolsDungeonMenu", DUNGEONS)
local openRaids    = BuildMenu("AdminToolsRaidMenu",    RAIDS)
local openGrindA   = BuildMenu("AdminToolsGrindAMenu",  GRIND_A)
local openGrindH   = BuildMenu("AdminToolsGrindHMenu",  GRIND_H)
local openTrainers = BuildMenu("AdminToolsTrainerMenu", TRAINERS)

---------------------------------------------------------------------------
-- TELE (grouped by faction, with enemy-capital warning)
---------------------------------------------------------------------------
do
	local p = pages["Tele"]
	local y = -2
	y = TeleSection(p, y, "Alliance", {
		{ "Stormwind", "stormwind",   "Alliance" },
		{ "Ironforge", "ironforge",   "Alliance" },
		{ "Darnassus", "darnassus",   "Alliance" },
		{ "The Exodar","theexodar",   "Alliance" },
	})
	y = TeleSection(p, y, "Horde", {
		{ "Orgrimmar",     "orgrimmar",    "Horde" },
		{ "Undercity",     "undercity",    "Horde" },
		{ "Thunder Bluff", "thunderbluff", "Horde" },
		{ "Silvermoon",    "silvermoon",   "Horde" },
	})
	y = TeleSection(p, y, "Neutral", {
		{ "Shattrath", "shattrath", "Neutral" },
		{ "Dalaran",   "dalaran",   "Neutral" },
		{ "Booty Bay", "bootybay",  "Neutral" },
		{ "Gadgetzan", "gadgetzan", "Neutral" },
	})

	y = FormRow(p, y - 2, "Tele to:",      function(t) return ".tele " .. t end)
	y = FormRow(p, y,     "Lookup tele:",  function(t) return ".lookup tele " .. t end)
	y = FormRow(p, y,     "Save spot as:", function(t) return ".tele add " .. t end)

	FlowButtons(p, {
		{ "Recall (undo)",   ".recall" },
		{ "Reset Instances", ".instance unbind all" },
	}, y - 4)

	local note = MakeLabel(p, "Tele names come from the server's game_tele table.")
	note:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", 4, 2)
end

---------------------------------------------------------------------------
-- TRAVEL (dungeon / raid / grinding-spot dropdowns)
---------------------------------------------------------------------------
do
	local p = pages["Travel"]
	local defs = {
		{ "Dungeons (por nivel) v",        openDungeons },
		{ "Raids (por nivel) v",           openRaids },
		{ "Zonas de Leveo - Alianza v",    openGrindA },
		{ "Zonas de Leveo - Horda v",      openGrindH },
	}
	for i, d in ipairs(defs) do
		local b = MakeButton(p, d[1], 260, d[2])
		b:SetPoint("TOPLEFT", p, "TOPLEFT", 8, -12 - (i - 1) * 30)
	end

	local note = MakeLabel(p, "Teleports drop you at the entrance / hub.  Dungeons are\n"
		.. "not faction-locked, so both sides see the full list; grinding\n"
		.. "spots are faction-specific.  If a teleport fails, the name is\n"
		.. "not in your server's game_tele table - use Tele tab > \"Lookup\n"
		.. "tele\" to find it, then edit the tables in AdminTools.lua.")
	note:SetJustifyH("LEFT")
	note:SetPoint("TOPLEFT", p, "TOPLEFT", 8, -140)
end

---------------------------------------------------------------------------
-- SELF
---------------------------------------------------------------------------
do
	local p = pages["Self"]
	FlowButtons(p, {
		{ "GM On",  ".gm on" },        { "GM Off", ".gm off" },        { "GM Chat", ".gmchat" },
		{ "Visible On", ".gm visible on" }, { "Visible Off", ".gm visible off" }, { "GM List", ".gm ingame" },
		{ "Fly On", ".gm fly on" },     { "Fly Off", ".gm fly off" },   { "Revive", ".revive" },
		{ "WaterWalk On", ".aura 546" }, { "WaterWalk Off", ".unaura 546" }, { "Remove Auras", ".unaura all" },
		{ "Clear CDs", ".cooldown clear" }, { "Explore Map", ".explorecheat 1" }, { "Max Skills", ".maxskill" },
		{ "Speed 1", ".modify speed 1" }, { "Speed 4", ".modify speed 4" }, { "Speed 7", ".modify speed 7" },
		{ "Speed 10", ".modify speed 10" }, { "Scale 1", ".modify scale 1" }, { "Scale 0.5", ".modify scale 0.5" },
	}, -4)
end

---------------------------------------------------------------------------
-- CHAR
---------------------------------------------------------------------------
do
	local p = pages["Char"]
	local y = FlowButtons(p, {
		{ "Level +1", ".levelup 1" }, { "Level +5", ".levelup 5" }, { "Level +10", ".levelup 10" },
		{ "Level -1", ".levelup -1" }, { "Reset Talents", ".reset talents" }, { "Reset Spells", ".reset spells" },
		{ "Learn Class", ".learn all_myclass" }, { "Learn All Spells", ".learn all_myspells" }, { "Learn Talents", ".learn all_mytalents" },
		{ "Learn Recipes", ".learn all_recipes" }, { "Learn Langs", ".learn all_lang" }, { "Learn GM Spells", ".learn all_gm" },
		{ "Repair Items", ".repairitems" }, { "+100g", ".modify money 1000000" }, { "+1000g", ".modify money 10000000" },
	}, -4)

	-- free max-capacity bags (22-slot Glacial Bag, itemID 41600)
	local bag1 = MakeButton(p, "Free Max Bag x1", BTN_W, ".additem " .. MAX_BAG_ID .. " 1")
	bag1:SetPoint("TOPLEFT", p, "TOPLEFT", 4, y)
	local bag4 = MakeButton(p, "Free Max Bags x4", BTN_W, ".additem " .. MAX_BAG_ID .. " 4")
	bag4:SetPoint("TOPLEFT", p, "TOPLEFT", 4 + (BTN_W + PAD), y)
	local mnt = MakeButton(p, "Monturas v", BTN_W, openMounts)
	mnt:SetPoint("TOPLEFT", p, "TOPLEFT", 4 + 2 * (BTN_W + PAD), y)
	y = y - (BTN_H + PAD) - 2

	y = FormRow2(p, y, "Add item (id  qty):", function(a, b)
		if b == "" then b = "1" end
		return ".additem " .. a .. " " .. b
	end)
	y = FormRow(p, y, "Add item set:",   function(t) return ".additemset " .. t end)
	y = FormRow(p, y, "Set level:",      function(t) return ".character level " .. t end)
	y = FormRow(p, y, "Give money (c):", function(t) return ".modify money " .. t end)
end

---------------------------------------------------------------------------
-- PARTY (other players)
---------------------------------------------------------------------------
do
	local p = pages["Party"]
	local y = FlowButtons(p, {
		{ "Summon My Group", ".groupsummon" }, { "Recall Target", ".recall" }, { "Kill Target", ".die" },
		{ "Revive Target", ".revive" },        { "Freeze", ".freeze" },        { "Unfreeze", ".unfreeze" },
	}, -4)

	y = FormRow(p, y - 4, "Appear to:",   function(t) return ".appear " .. t end)
	y = FormRow(p, y,     "Summon:",      function(t) return ".summon " .. t end)
	y = FormRow(p, y,     "Player info:", function(t) return ".pinfo " .. t end)
	y = FormRow(p, y,     "Revive:",      function(t) return ".revive " .. t end)
	y = FormRow(p, y,     "Kick:",        function(t) return ".kick " .. t end)
end

---------------------------------------------------------------------------
-- SUMMON (temporary helper NPCs - real Blizzard vendor/trainer/banker/
-- auctioneer creatures, spawned with ".npc add temp <entry>", never saved
-- to the database.  Faction-matched so the right one is usable by your
-- character.  There is no GM command for an automatic timed despawn, so
-- use "Dismiss Helper" when you're done, or they clear themselves on the
-- next server restart.)
---------------------------------------------------------------------------
do
	local p = pages["Summon"]
	local y = -2

	local hA = MakeLabel(p, "Alliance", "GameFontNormal")
	hA:SetPoint("TOPLEFT", p, "TOPLEFT", 6, y)
	y = y - 16
	y = FlowButtons(p, {
		{ "General Vendor",      ".npc add temp 74" },
		{ "Food & Drink Vendor", ".npc add temp 274" },
		{ "Auctioneer",          ".npc add temp 8719" },
		{ "Banker",              ".npc add temp 2455" },
	}, y)
	y = y - 4

	local hH = MakeLabel(p, "Horde", "GameFontNormal")
	hH:SetPoint("TOPLEFT", p, "TOPLEFT", 6, y)
	y = y - 16
	y = FlowButtons(p, {
		{ "General Vendor",      ".npc add temp 980" },
		{ "Food & Drink Vendor", ".npc add temp 982" },
		{ "Auctioneer",          ".npc add temp 8673" },
		{ "Banker",              ".npc add temp 3309" },
	}, y)
	y = y - 4

	local trainerBtn = MakeButton(p, "Instructores v", BTN_W, openTrainers)
	trainerBtn:SetPoint("TOPLEFT", p, "TOPLEFT", 4, y)
	local dismissBtn = MakeButton(p, "Dismiss Helper", BTN_W, ".npc delete")
	dismissBtn:SetPoint("TOPLEFT", p, "TOPLEFT", 4 + (BTN_W + PAD), y)
	y = y - (BTN_H + PAD) - 6

	local note = MakeLabel(p, "Real, temporary NPCs - talk to them like any normal\n"
		.. "vendor / trainer / banker / auctioneer.  Never saved to the\n"
		.. "server; a restart clears them.  No GM command exists for a\n"
		.. "timed auto-despawn, so target the helper and click\n"
		.. "\"Dismiss Helper\" when you're done.")
	note:SetJustifyH("LEFT")
	note:SetPoint("TOPLEFT", p, "TOPLEFT", 4, y)
end

---------------------------------------------------------------------------
-- SERVER
---------------------------------------------------------------------------
do
	local p = pages["Server"]
	local y = FlowButtons(p, {
		{ "Server Info", ".server info" }, { "GPS", ".gps" },            { "Save All", ".saveall" },
		{ "My Account",  ".account" },     { "Online List", ".gm ingame" }, { "Cancel Shutdown", ".server shutdown cancel" },
		{ "Shutdown 60s", function() ConfirmCmd(".server shutdown 60") end },
		{ "Restart 60s",  function() ConfirmCmd(".server restart 60") end },
		{ "Shutdown 5m",  function() ConfirmCmd(".server shutdown 300") end },
	}, -4)

	y = FormRow(p, y - 4, "Announce:",       function(t) return ".announce " .. t end)
	y = FormRow(p, y,     "Set MOTD:",       function(t) return ".server set motd " .. t end)
	y = FormRow(p, y,     "Shutdown (sec):", function(t) return ".server shutdown " .. t end)
	y = FormRow(p, y,     "Restart (sec):",  function(t) return ".server restart " .. t end)
end

---------------------------------------------------------------------------
-- CUSTOM
---------------------------------------------------------------------------
local customPool = {}
local function RefreshCustom()
	local p = pages["Custom"]
	for _, b in ipairs(customPool) do b:Hide() end
	local list = (AdminToolsDB and AdminToolsDB.custom) or {}
	for i, item in ipairs(list) do
		local b = customPool[i]
		if not b then
			b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
			b:SetSize(196, 22)
			b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			customPool[i] = b
		end
		b._idx = i
		b:SetText(item.label)
		b:SetScript("OnClick", function(self, mouse)
			if mouse == "RightButton" then
				local d = StaticPopup_Show("ADMINTOOLS_DELCUSTOM")
				if d then d.data = self._idx end
			else
				RunCmd(item.cmd)
			end
		end)
		local col = (i - 1) % 2
		local row = floor((i - 1) / 2)
		b:SetPoint("TOPLEFT", p, "TOPLEFT", 4 + col * 204, -104 - row * 26)
		b:Show()
	end
end

StaticPopupDialogs["ADMINTOOLS_DELCUSTOM"] = {
	text = "Remove this custom button?",
	button1 = YES, button2 = NO,
	OnAccept = function(self, data)
		if AdminToolsDB and AdminToolsDB.custom then
			table.remove(AdminToolsDB.custom, data)
			RefreshCustom()
		end
	end,
	timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

do
	local p = pages["Custom"]
	local head = MakeLabel(p, "Left-click runs.  Right-click removes.")
	head:SetPoint("TOPLEFT", p, "TOPLEFT", 4, -2)

	local l1 = MakeLabel(p, "Label:")
	l1:SetPoint("TOPLEFT", p, "TOPLEFT", 6, -26)
	local eLabel = MakeEdit(p, 150)
	eLabel:SetPoint("TOPLEFT", p, "TOPLEFT", 90, -22)

	local l2 = MakeLabel(p, "Command:")
	l2:SetPoint("TOPLEFT", p, "TOPLEFT", 6, -52)
	local eCmd = MakeEdit(p, 300)
	eCmd:SetPoint("TOPLEFT", p, "TOPLEFT", 90, -48)

	local add = MakeButton(p, "Add Button", 100, function()
		local lab = strtrim(eLabel:GetText() or "")
		local cmd = strtrim(eCmd:GetText() or "")
		if lab == "" or cmd == "" then return end
		AdminToolsDB.custom = AdminToolsDB.custom or {}
		tinsert(AdminToolsDB.custom, { label = lab, cmd = cmd })
		eLabel:SetText(""); eCmd:SetText(""); eLabel:ClearFocus(); eCmd:ClearFocus()
		RefreshCustom()
	end)
	add:SetPoint("TOPLEFT", p, "TOPLEFT", 90, -74)
end

---------------------------------------------------------------------------
-- Slash + init
---------------------------------------------------------------------------
SLASH_ADMINTOOLS1 = "/admin"
SLASH_ADMINTOOLS2 = "/adt"
SLASH_ADMINTOOLS3 = "/wpadm"
SLASH_ADMINTOOLS4 = "/wpgm"
SLASH_ADMINTOOLS5 = "/admintools"
SlashCmdList["ADMINTOOLS"] = function(msg)
	msg = strtrim(msg or "")
	if msg ~= "" then RunCmd(msg); return end
	if f:IsShown() then f:Hide() else f:Show() end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(self, event, name)
	if name ~= ADDON then return end
	AdminToolsDB = AdminToolsDB or {}
	AdminToolsDB.custom = AdminToolsDB.custom or {}
	if AdminToolsDB.pos then
		f:ClearAllPoints()
		f:SetPoint(AdminToolsDB.pos[1], UIParent, AdminToolsDB.pos[2], AdminToolsDB.pos[3], AdminToolsDB.pos[4])
	end
	RefreshCustom()
	ShowPage(AdminToolsDB.tab or "Tele")
	self:UnregisterEvent("ADDON_LOADED")
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD700[WoW Perú]|r |cFF00FFCCAdmin Tools|r v2.0.1 cargado. Usa |cFFFFD700/admin|r, |cFFFFD700/wpadm|r o |cFFFFD700/wpgm|r.")
end)
