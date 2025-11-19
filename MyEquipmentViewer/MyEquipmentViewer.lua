-- Список слотов (порядок важен для отображения сверху вниз)
local slots = {
    "HeadSlot", 
    "NeckSlot", 
    "ShoulderSlot", 
    "ShirtSlot", 
    "ChestSlot",
    "WaistSlot", 
    "LegsSlot", 
    "FeetSlot", 
    "WristSlot", 
    "HandsSlot",
    "Finger0Slot", 
    "Finger1Slot", 
    "Trinket0Slot", 
    "Trinket1Slot",
    "BackSlot", 
    "MainHandSlot", 
    "SecondaryHandSlot",
    "RangedSlot", 
    "TabardSlot"
}

-- Перевод названий слотов (для отображения, если предмет не одет)
local slotNamesRU = {
    HeadSlot = "Голова", 
    NeckSlot = "Шея", 
    ShoulderSlot = "Плечи", 
    ShirtSlot = "Рубашка",
    ChestSlot = "Грудь", 
    WaistSlot = "Пояс", 
    LegsSlot = "Ноги", 
    FeetSlot = "Обувь",
    WristSlot = "Запястья", 
    HandsSlot = "Кисти рук", 
    Finger0Slot = "Кольцо 1", 
    Finger1Slot = "Кольцо 2",
    Trinket0Slot = "Аксессуар 1", 
    Trinket1Slot = "Аксессуар 2", 
    BackSlot = "Спина",
    MainHandSlot = "Правая рука", 
    SecondaryHandSlot = "Левая рука", 
    RangedSlot = "Дальний бой", 
    TabardSlot = "Накидка"
}

local MyEquipmentFrame = nil
local slotButtons = {}

local function UpdateEquipmentDisplay()
    if not MyEquipmentFrame then return end
    if not MyEquipmentFrame:IsVisible() then return end

    for i, slotName in ipairs(slots) do
        local slotFrame = slotButtons[slotName]
        local slotId = GetInventorySlotInfo(slotName)

        -- Создание строки (если ещё нет)
        if not slotFrame then
            -- Создаем простую кнопку (без шаблона иконки)
            local buttonName = "MyEquipItem_"..slotName
            slotFrame = CreateFrame("Button", buttonName, MyEquipmentFrame)
            
            -- Размер кнопки под текст
            slotFrame:SetWidth(230)
            slotFrame:SetHeight(18) 
            
            -- Расположение: одна колонка, друг под другом
            slotFrame:SetPoint("TOPLEFT", 10, -35 - (i-1)*18)
            
            -- Сохраняем ID для тултипа
            slotFrame.oid = slotId 
            
            -- Создаем текстовое поле внутри кнопки
            slotFrame.text = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            slotFrame.text:SetPoint("LEFT", slotFrame, "LEFT", 5, 0)
            slotFrame.text:SetJustifyH("LEFT") -- Выравнивание текста по левому краю
            
            slotButtons[slotName] = slotFrame

            -- Тултип (подсказка) при наведении на текст
            slotFrame:SetScript("OnEnter", function()
                -- Подсветка строки при наведении
                this.text:SetFontObject("GameFontHighlightSmall")
                
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                if ( this.oid ) then
                    GameTooltip:SetInventoryItem("player", this.oid)
                end
                GameTooltip:Show()
            end)
            
            slotFrame:SetScript("OnLeave", function()
                -- Возвращаем обычный шрифт
                this.text:SetFontObject("GameFontNormalSmall")
                GameTooltip:Hide()
            end)
            
            -- Можно добавить клик (например, чтобы линкануть в чат), 
            -- но пока просто оставляем как заглушку
            slotFrame:RegisterForClicks("LeftButtonUp") 
        end

        -- Получаем ссылку на предмет
        local itemLink = GetInventoryItemLink("player", slotId)

        if itemLink then
            -- ВАЖНО: itemLink уже содержит цвет и название в скобках!
            -- Например: "|cffa335ee[Эпический меч]|r"
            -- Мы просто устанавливаем этот текст, и игра сама его раскрасит.
            slotFrame.text:SetText(itemLink)
        else
            -- Если предмета нет, пишем название слота серым цветом
            local emptyText = slotNamesRU[slotName] or slotName
            slotFrame.text:SetText("|cff808080<"..emptyText..">|r")
        end
    end
end

local function CreateEquipmentFrame()
    if MyEquipmentFrame then return end

    -- Создаём фрейм
    MyEquipmentFrame = CreateFrame("Frame", "MyEquipmentFrame", PaperDollFrame)
    
    -- Увеличили ширину под длинные названия
    MyEquipmentFrame:SetWidth(250) 
    -- Высота под список (19 слотов * 18px + отступы)
    MyEquipmentFrame:SetHeight(400) 
    
    MyEquipmentFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -30, -10)
    
    MyEquipmentFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    MyEquipmentFrame:SetBackdropColor(0, 0, 0, 0.8)

    local title = MyEquipmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetText("Экипировка")
    title:SetPoint("TOP", 0, -10)

    MyEquipmentFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    MyEquipmentFrame:SetScript("OnEvent", function()
        if event == "PLAYER_EQUIPMENT_CHANGED" then
            UpdateEquipmentDisplay()
        end
    end)

    MyEquipmentFrame:SetScript("OnShow", UpdateEquipmentDisplay)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    CreateEquipmentFrame()

end)
