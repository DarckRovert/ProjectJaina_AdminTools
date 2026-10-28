--=========================================================================
-- Project Jaina — AdminTools Armory & Live Equipment Editor (v3.0)
-- Módulo #20 del Ecosistema Project Jaina (WotLK 3.3.5a)
-- 
-- Permite inspeccionar en tiempo real el equipamiento de cualquier objetivo
-- (jugador humano o bot), visualizar sus 19 casillas de inventario con
-- iconos, bordes de calidad y tooltips nativos, y equipar/retirar ítems
-- o conjuntos épicos directamente sin salir del juego.
--=========================================================================

local ADDON, NS = ...
local AT = AdminTools

if not AT then
    AT = {}
    AdminTools = AT
end

-- Client-side asynchronous frame delay for WoW 3.3.5a UI
local delayFrame = CreateFrame("Frame")
local pendingTimers = {}
delayFrame:SetScript("OnUpdate", function(self, elapsed)
    local i = 1
    while i <= #pendingTimers do
        local entry = pendingTimers[i]
        entry.delay = entry.delay - elapsed
        if entry.delay <= 0 then
            table.remove(pendingTimers, i)
            if entry.callback then
                pcall(entry.callback)
            end
        else
            i = i + 1
        end
    end
end)

local function ClientDelay(delaySec, callback)
    table.insert(pendingTimers, { delay = delaySec, callback = callback })
end
AT.ClientDelay = ClientDelay

local SLOTS = {
    -- Columna Izquierda (8 casillas)
    { id = 1,  name = "Cabeza",          side = "LEFT",  row = 0, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head" },
    { id = 2,  name = "Cuello",          side = "LEFT",  row = 1, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck" },
    { id = 3,  name = "Hombros",         side = "LEFT",  row = 2, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder" },
    { id = 15, name = "Capa (Espalda)",   side = "LEFT",  row = 3, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest" },
    { id = 5,  name = "Pecho",           side = "LEFT",  row = 4, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest" },
    { id = 4,  name = "Camisa",          side = "LEFT",  row = 5, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shirt" },
    { id = 19, name = "Tabardo",         side = "LEFT",  row = 6, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Tabard" },
    { id = 9,  name = "Muñecas",         side = "LEFT",  row = 7, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists" },

    -- Columna Derecha (8 casillas)
    { id = 10, name = "Manos",           side = "RIGHT", row = 0, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands" },
    { id = 6,  name = "Cinturón",        side = "RIGHT", row = 1, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist" },
    { id = 7,  name = "Piernas",         side = "RIGHT", row = 2, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs" },
    { id = 8,  name = "Pies",            side = "RIGHT", row = 3, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet" },
    { id = 11, name = "Anillo 1",        side = "RIGHT", row = 4, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger" },
    { id = 12, name = "Anillo 2",        side = "RIGHT", row = 5, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger" },
    { id = 13, name = "Abalorio 1",      side = "RIGHT", row = 6, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket" },
    { id = 14, name = "Abalorio 2",      side = "RIGHT", row = 7, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket" },

    -- Fila Inferior (Armas y Reliquias)
    { id = 16, name = "Mano Principal",  side = "BOTTOM", col = 0, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand" },
    { id = 17, name = "Mano Secundaria", side = "BOTTOM", col = 1, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand" },
    { id = 18, name = "A Distancia",     side = "BOTTOM", col = 2, defaultIcon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged" },
}

-- Conjuntos Tier y PvP oficiales de WotLK 3.3.5a para AddItemSet
local ARMORY_ITEMSETS = {
    { "Tier 7 (Naxxramas 25)", {
        { "Guerrero DPS (T7)",       ".additem set 801" },
        { "Guerrero Protección (T7)", ".additem set 802" },
        { "Paladín Reprensión (T7)",  ".additem set 807" },
        { "Paladín Sagrado (T7)",     ".additem set 808" },
        { "Paladín Protección (T7)",  ".additem set 809" },
        { "Caballero Muerte DPS (T7)", ".additem set 796" },
        { "Caballero Muerte Tank (T7)",".additem set 797" },
        { "Cazador (T7)",             ".additem set 804" },
        { "Chamán Mejora (T7)",       ".additem set 814" },
        { "Chamán Elemental (T7)",    ".additem set 815" },
        { "Chamán Restauración (T7)", ".additem set 816" },
        { "Pícaro (T7)",              ".additem set 817" },
        { "Druida Feral (T7)",        ".additem set 798" },
        { "Druida Equilibrio (T7)",   ".additem set 799" },
        { "Druida Restauración (T7)", ".additem set 800" },
        { "Mago (T7)",                ".additem set 805" },
        { "Brujo (T7)",               ".additem set 818" },
        { "Sacerdote Sombras (T7)",   ".additem set 811" },
        { "Sacerdote Sagrado (T7)",   ".additem set 812" },
    } },
    { "Tier 8 (Ulduar 25)", {
        { "Guerrero DPS (T8)",       ".additem set 834" },
        { "Guerrero Protección (T8)", ".additem set 835" },
        { "Paladín Reprensión (T8)",  ".additem set 840" },
        { "Paladín Sagrado (T8)",     ".additem set 841" },
        { "Paladín Protección (T8)",  ".additem set 842" },
        { "Caballero Muerte DPS (T8)", ".additem set 828" },
        { "Caballero Muerte Tank (T8)",".additem set 829" },
        { "Cazador (T8)",             ".additem set 837" },
        { "Pícaro (T8)",              ".additem set 846" },
        { "Mago (T8)",                ".additem set 838" },
        { "Brujo (T8)",               ".additem set 847" },
        { "Sacerdote (T8)",           ".additem set 844" },
    } },
    { "Tier 9 (Trial of the Crusader 25H)", {
        { "Guerrero DPS (T9)",       ".additem set 857" },
        { "Paladín Reprensión (T9)",  ".additem set 863" },
        { "Caballero Muerte DPS (T9)", ".additem set 851" },
        { "Cazador (T9)",             ".additem set 860" },
        { "Pícaro (T9)",              ".additem set 869" },
        { "Mago (T9)",                ".additem set 861" },
        { "Brujo (T9)",               ".additem set 870" },
        { "Sacerdote (T9)",           ".additem set 867" },
    } },
    { "Tier 10 (Icecrown Citadel 25H)", {
        { "Guerrero DPS (T10)",       ".additem set 901" },
        { "Guerrero Protección (T10)", ".additem set 902" },
        { "Paladín Reprensión (T10)",  ".additem set 907" },
        { "Paladín Sagrado (T10)",     ".additem set 908" },
        { "Paladín Protección (T10)",  ".additem set 909" },
        { "Caballero Muerte DPS (T10)",".additem set 897" },
        { "Caballero Muerte Tank (T10)",".additem set 898" },
        { "Cazador (T10)",             ".additem set 904" },
        { "Pícaro (T10)",              ".additem set 913" },
        { "Mago (T10)",                ".additem set 905" },
        { "Brujo (T10)",               ".additem set 914" },
        { "Sacerdote Sombras (T10)",   ".additem set 911" },
        { "Sacerdote Sagrado (T10)",   ".additem set 912" },
    } },
    { "PvP Season 8 (Gladiador Colérico)", {
        { "Guerrero Colérico",        ".additem set 920" },
        { "Paladín Colérico",         ".additem set 923" },
        { "Caballero Muerte Colérico",".additem set 917" },
        { "Cazador Colérico",         ".additem set 921" },
        { "Chamán Colérico",          ".additem set 926" },
        { "Pícaro Colérico",          ".additem set 925" },
        { "Druida Colérico",          ".additem set 919" },
        { "Mago Colérico",            ".additem set 922" },
        { "Brujo Colérico",           ".additem set 927" },
        { "Sacerdote Colérico",       ".additem set 924" },
    } },
}

local armorySlots = {}
local targetHeaderLabel = nil
local targetMetaLabel = nil
local itemInputBox = nil
local qtyInputBox = nil
local currentInspectedUnit = "player"

-- Helper para extraer el ID numérico de un ítem ya sea desde string simple o enlace [ItemLink]
local function ExtractItemId(text)
    if not text then return nil end
    text = strtrim(text)
    local fromLink = text:match("item:(%d+)")
    if fromLink then return fromLink end
    local pureNumber = text:match("^(%d+)$")
    if pureNumber then return pureNumber end
    return nil
end

-- Actualiza la visualización de una casilla individual
local function RefreshSlotButton(slotBtn, unit)
    local slotId = slotBtn.slotId
    local link = GetInventoryItemLink(unit, slotId)
    local texture = GetInventoryItemTexture(unit, slotId)

    if link then
        local itemName, _, itemQuality, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(link)
        slotBtn.icon:SetTexture(itemTexture or texture or slotBtn.defaultIcon)
        slotBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local r, g, b = GetItemQualityColor(itemQuality or 1)
        slotBtn.border:SetVertexColor(r, g, b, 1)
        slotBtn.border:Show()

        if itemLevel and itemLevel > 1 then
            slotBtn.ilvl:SetText(tostring(itemLevel))
        else
            slotBtn.ilvl:SetText("")
        end

        slotBtn.itemLink = link
        slotBtn.itemId = link:match("item:(%d+)")
    else
        slotBtn.icon:SetTexture(slotBtn.defaultIcon)
        slotBtn.icon:SetTexCoord(0, 1, 0, 1)
        slotBtn.border:Hide()
        slotBtn.ilvl:SetText("")
        slotBtn.itemLink = nil
        slotBtn.itemId = nil
    end
end

-- Actualiza todas las casillas y la cabecera
function AT.RefreshArmory(unit)
    if not unit then
        unit = UnitExists("target") and "target" or "player"
    end
    currentInspectedUnit = unit

    if not UnitExists(unit) then
        unit = "player"
        currentInspectedUnit = "player"
    end

    local name = UnitName(unit) or "Desconocido"
    local lvl = UnitLevel(unit) or 0
    local class = UnitClass(unit) or "Clase"
    local race = UnitRace(unit) or "Raza"
    local isPlayer = UnitIsPlayer(unit)

    local isBot = false
    local lowerName = name:lower()
    if lowerName:find("^rndbot") or lowerName:find("^wanibot") or lowerName:find("^bot_") then
        isBot = true
    end

    local typeTag = isBot and "|cFF00FFFF[BOT INTELIGENTE]|r" or (isPlayer and "|cFF00FF00[JUGADOR REAL]|r" or "|cFFFF8800[NPC / CRIATURA]|r")
    if unit == "player" then
        typeTag = "|cFFFFD700[TÚ MISMO - GAME MASTER]|r"
    end

    if targetHeaderLabel then
        targetHeaderLabel:SetText(string.format("|cFFFFD700Objetivo:|r |cFFFFFFFF%s|r  %s", name, typeTag))
    end
    if targetMetaLabel then
        targetMetaLabel:SetText(string.format("|cFF888888Nivel:|r |cFFFFD100%s|r   |cFF888888Raza:|r |cFFFFFFFF%s|r   |cFF888888Clase:|r |cFFFFFFFF%s|r",
            (lvl > 0 and tostring(lvl) or "??"), race, class))
    end

    -- Si el objetivo es target y es jugador, solicitar paquete de inspección
    if unit == "target" and CanInspect("target") then
        pcall(function() NotifyInspect("target") end)
    end

    -- Refrescar cada una de las 19 casillas
    for _, slotBtn in ipairs(armorySlots) do
        RefreshSlotButton(slotBtn, unit)
    end
end

-- Constructor de la página de Armería
function AT.InitArmory(page)
    if page._armoryInitialized then return end
    page._armoryInitialized = true

    -- 1. Cabecera del Objetivo
    targetHeaderLabel = AT.MakeLabel(page, "Objetivo: Cargando...", "GameFontHighlightLarge")
    targetHeaderLabel:SetPoint("TOPLEFT", page, "TOPLEFT", 12, -4)

    targetMetaLabel = AT.MakeLabel(page, "Nivel: -- | Raza: -- | Clase: --", "GameFontNormalSmall")
    targetMetaLabel:SetPoint("TOPLEFT", page, "TOPLEFT", 12, -26)

    local btnInspectSelf = AT.MakeButton(page, "Inspeccionar GM", 114, function()
        AT.RefreshArmory("player")
    end)
    btnInspectSelf:SetPoint("TOPRIGHT", page, "TOPRIGHT", -12, -4)

    local btnInspectTarget = AT.MakeButton(page, "Inspeccionar Target", 136, function()
        AT.RefreshArmory("target")
    end)
    btnInspectTarget:SetPoint("RIGHT", btnInspectSelf, "LEFT", -6, 0)

    -- 2. Creación de los 19 Slots Interactivos
    local SLOT_SIZE = 34
    local LEFT_X = 12
    local RIGHT_X = 586
    local START_Y = -52
    local STEP_Y = 38

    for _, def in ipairs(SLOTS) do
        local slotBtn = CreateFrame("Button", nil, page)
        slotBtn:SetSize(SLOT_SIZE, SLOT_SIZE)
        slotBtn.slotId = def.id
        slotBtn.slotName = def.name
        slotBtn.defaultIcon = def.defaultIcon

        -- Fondo del botón
        local bg = slotBtn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(0, 0, 0, 0.6)

        -- Icono del ítem
        local icon = slotBtn:CreateTexture(nil, "BORDER")
        icon:SetSize(30, 30)
        icon:SetPoint("CENTER")
        icon:SetTexture(def.defaultIcon)
        slotBtn.icon = icon

        -- Borde de Calidad (Verde, Azul, Épico, Legendario)
        local border = slotBtn:CreateTexture(nil, "OVERLAY")
        border:SetSize(46, 46)
        border:SetPoint("CENTER", 0, 0)
        border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        border:SetBlendMode("ADD")
        border:Hide()
        slotBtn.border = border

        -- Nivel de Objeto (iLvl) en la esquina inferior derecha
        local ilvl = slotBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ilvl:SetPoint("BOTTOMRIGHT", slotBtn, "BOTTOMRIGHT", -2, 2)
        ilvl:SetTextColor(1, 1, 0.4)
        slotBtn.ilvl = ilvl

        -- Highlight en Mouseover
        local hl = slotBtn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        hl:SetBlendMode("ADD")

        -- Posicionamiento según columna
        if def.side == "LEFT" then
            slotBtn:SetPoint("TOPLEFT", page, "TOPLEFT", LEFT_X, START_Y - (def.row * STEP_Y))
        elseif def.side == "RIGHT" then
            slotBtn:SetPoint("TOPLEFT", page, "TOPLEFT", RIGHT_X, START_Y - (def.row * STEP_Y))
        elseif def.side == "BOTTOM" then
            local baseX = 246 + (def.col * 46)
            slotBtn:SetPoint("TOPLEFT", page, "TOPLEFT", baseX, -370)
        end

        -- Handlers de Tooltip y Clic
        slotBtn:SetScript("OnEnter", function(self)
            if self.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.itemLink)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFF00FFCC[Clic Izquierdo]|r Copiar ID al panel de entrega.", 0.2, 1, 0.8)
                GameTooltip:AddLine("|cFFFF2020[Clic Derecho]|r Quitar este ítem del objetivo.", 1, 0.3, 0.3)
                GameTooltip:Show()
            else
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.slotName, 1, 1, 1)
                GameTooltip:AddLine("Casilla vacía.", 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end
        end)

        slotBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        slotBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slotBtn:SetScript("OnClick", function(self, button)
            if button == "RightButton" and self.itemId then
                if UnitExists("target") and not UnitIsUnit("target", "player") then
                    pcall(function()
                        SendChatMessage("unequip " .. self.itemId, "WHISPER", nil, UnitName("target"))
                    end)
                end
                AT.RunCmd(string.format(".additem %s -1", self.itemId))
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFFD700[AdminTools]|r Retirando ítem %s del objetivo...", self.itemLink or self.itemId))
                -- Refrescar tras medio segundo
                ClientDelay(0.6, function() AT.RefreshArmory(currentInspectedUnit) end)
            elseif button == "LeftButton" and self.itemId and itemInputBox then
                itemInputBox:SetText(self.itemId)
                itemInputBox:HighlightText()
                itemInputBox:SetFocus()
            end
        end)

        table.insert(armorySlots, slotBtn)
    end

    -- 3. Panel Central de Entrega y Modificación de Ítems
    local centerX = 64
    local centerY = -54

    local panelHeader = AT.MakeLabel(page, "|cFF00FFCCEconómica y Gestión de Objetos en Vivo:|r", "GameFontNormal")
    panelHeader:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY)
    centerY = centerY - 24

    -- Input de Ítem ID o Enlace Shift-Click
    local lblItem = AT.MakeLabel(page, "Ítem (ID o Shift-Click):", "GameFontHighlightSmall")
    lblItem:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY - 2)

    itemInputBox = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
    itemInputBox:SetSize(160, 20)
    itemInputBox:SetPoint("LEFT", lblItem, "RIGHT", 10, 0)
    itemInputBox:SetAutoFocus(false)
    itemInputBox:SetScript("OnEscapePressed", itemInputBox.ClearFocus)

    local lblQty = AT.MakeLabel(page, "Cant:", "GameFontHighlightSmall")
    lblQty:SetPoint("LEFT", itemInputBox, "RIGHT", 10, 0)

    qtyInputBox = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
    qtyInputBox:SetSize(36, 20)
    qtyInputBox:SetPoint("LEFT", lblQty, "RIGHT", 6, 0)
    qtyInputBox:SetText("1")
    qtyInputBox:SetAutoFocus(false)
    qtyInputBox:SetScript("OnEscapePressed", qtyInputBox.ClearFocus)

    -- Botón de Equipar / Dar
    local function FireGiveItem()
        local rawText = itemInputBox:GetText()
        local id = ExtractItemId(rawText)
        local qty = tonumber(strtrim(qtyInputBox:GetText() or "1")) or 1
        if id then
            AT.RunCmd(string.format(".additem %s %d", id, qty))
            -- Si es un bot, ordenarle equipar mejoras inmediatamente por whisper y party
            pcall(function()
                if UnitExists("target") and UnitName("target") then
                    SendChatMessage("equip", "WHISPER", nil, UnitName("target"))
                end
                SendChatMessage("equip", "PARTY")
            end)
            itemInputBox:SetText("")
            itemInputBox:ClearFocus()
            ClientDelay(0.8, function() AT.RefreshArmory(currentInspectedUnit) end)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2020[AdminTools]|r Por favor ingresa un ID numérico o Shift-Clicka un ítem válido.")
        end
    end

    local btnGive = AT.MakeButton(page, "Dar / Equipar", 98, FireGiveItem)
    btnGive:SetPoint("LEFT", qtyInputBox, "RIGHT", 8, 0)

    -- Botón de Quitar
    local btnRemove = AT.MakeButton(page, "Quitar Ítem", 84, function()
        local rawText = itemInputBox:GetText()
        local id = ExtractItemId(rawText)
        local qty = tonumber(strtrim(qtyInputBox:GetText() or "1")) or 1
        if id then
            AT.RunCmd(string.format(".additem %s -%d", id, qty))
            itemInputBox:SetText("")
            itemInputBox:ClearFocus()
            ClientDelay(0.8, function() AT.RefreshArmory(currentInspectedUnit) end)
        end
    end)
    btnRemove:SetPoint("LEFT", btnGive, "RIGHT", 6, 0)

    itemInputBox:SetScript("OnEnterPressed", function()
        FireGiveItem()
    end)

    -- 4. Regear Épico para Bots y Jugadores
    centerY = centerY - 38
    local lblRegear = AT.MakeLabel(page, "|cFFFFD700Regear Automático de Bot (Armadura Épica Completa):|r", "GameFontNormal")
    lblRegear:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY)
    centerY = centerY - 20

    local btnRegear80 = AT.MakeButton(page, "Regear 80 Épico", 126, function()
        AT.RunCmd(".playerbots regear 80")
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[AdminTools]|r Reequipando bot objetivo con conjunto épico completo de nivel 80...")
        ClientDelay(1.0, function() AT.RefreshArmory(currentInspectedUnit) end)
    end)
    btnRegear80:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY)

    local btnRegear70 = AT.MakeButton(page, "Regear 70 Épico", 126, function()
        AT.RunCmd(".playerbots regear 70")
        ClientDelay(1.0, function() AT.RefreshArmory(currentInspectedUnit) end)
    end)
    btnRegear70:SetPoint("LEFT", btnRegear80, "RIGHT", 6, 0)

    local btnRegear60 = AT.MakeButton(page, "Regear 60 Épico", 126, function()
        AT.RunCmd(".playerbots regear 60")
        ClientDelay(1.0, function() AT.RefreshArmory(currentInspectedUnit) end)
    end)
    btnRegear60:SetPoint("LEFT", btnRegear70, "RIGHT", 6, 0)

    local btnEquipUpgrades = AT.MakeButton(page, "Forzar Equipar", 106, function()
        SendChatMessage("equip", "PARTY")
        ClientDelay(0.6, function() AT.RefreshArmory(currentInspectedUnit) end)
    end)
    btnEquipUpgrades:SetPoint("LEFT", btnRegear60, "RIGHT", 6, 0)

    -- 5. Catálogo Rápido de Conjuntos Tier y PvP
    centerY = centerY - 36
    local lblSets = AT.MakeLabel(page, "|cFFFFD700Conjuntos de Armadura Oficiales (Tier 7-10 & PvP S8):|r", "GameFontNormal")
    lblSets:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY)
    centerY = centerY - 20

    local openItemSetsMenu = AT.BuildMenu("AdminToolsItemSetsMenu", ARMORY_ITEMSETS)
    local btnSetsMenu = AT.MakeButton(page, "Seleccionar Conjunto Tier / PvP v", 260, openItemSetsMenu)
    btnSetsMenu:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY)

    local btnBags = AT.MakeButton(page, "4x Bolsas 22c", 110, function()
        AT.RunCmd(".additem 41600 4")
    end)
    btnBags:SetPoint("LEFT", btnSetsMenu, "RIGHT", 8, 0)

    local btnRepair = AT.MakeButton(page, "Reparar Todo", 110, function()
        AT.RunCmd(".repairitems")
    end)
    btnRepair:SetPoint("LEFT", btnBags, "RIGHT", 8, 0)

    -- 6. Guía y Atajos
    centerY = centerY - 40
    local guideNote = AT.MakeLabel(page,
        "|cFF888888Instrucciones de Uso de la Armería Game Master:|r\n"
        .. "1. |cFFFFFFFFSelecciona cualquier objetivo|r (jugador o bot) y se sincronizarán sus 19 casillas.\n"
        .. "2. |cFFFFD100Pasa el cursor|r sobre cualquier slot para ver estadísticas, encantamientos y gemas.\n"
        .. "3. |cFF00FF00Clic Izquierdo|r en un slot copia su ID al cuadro de texto de entrega.\n"
        .. "4. |cFFFF2020Clic Derecho|r en un slot retira instantáneamente la pieza del personaje.\n"
        .. "5. Pulsa |cFFFFFFFF'Regear 80 Épico'|r para equipar a cualquier bot con armadura suprema completa.",
        "GameFontNormalSmall"
    )
    guideNote:SetJustifyH("LEFT")
    guideNote:SetPoint("TOPLEFT", page, "TOPLEFT", centerX, centerY)

    -- Listeners de eventos de inspección
    local watcher = CreateFrame("Frame", nil, page)
    watcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    watcher:RegisterEvent("INSPECT_READY")
    watcher:SetScript("OnEvent", function(self, event, guid)
        if page:IsShown() then
            AT.RefreshArmory(UnitExists("target") and "target" or "player")
        end
    end)

    page:SetScript("OnShow", function()
        AT.RefreshArmory(UnitExists("target") and "target" or "player")
    end)
end

print("|cFFFFD700[Project Jaina]|r >> AdminToolsArmory.lua (Live Equipment Editor) cargado exitosamente.")
