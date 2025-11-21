-- Список слотов (порядок отображения сверху вниз)
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

-- Перевод названий слотов (для пустых ячеек)
local slotNamesRU = {
	HeadSlot          = "Голова",
	NeckSlot          = "Шея",
	ShoulderSlot      = "Плечи",
	ShirtSlot         = "Рубашка",
	ChestSlot         = "Грудь",
	WaistSlot         = "Пояс",
	LegsSlot          = "Ноги",
	FeetSlot          = "Обувь",
	WristSlot         = "Запястья",
	HandsSlot         = "Кисти рук",
	Finger0Slot       = "Кольцо 1",
	Finger1Slot       = "Кольцо 2",
	Trinket0Slot      = "Аксессуар 1",
	Trinket1Slot      = "Аксессуар 2",
	BackSlot          = "Спина",
	MainHandSlot      = "Правая рука",
	SecondaryHandSlot = "Левая рука",
	RangedSlot        = "Дальний бой",
	TabardSlot        = "Накидка"
}

-- Таблицы для хранения окон и кнопок
local Frames = {
	Player = nil,
	Inspect = nil
}
local Buttons = {
	Player = {},
	Inspect = {}
}

local function UpdateUnitGear(parentFrame, buttonsTable, unit)
	if not parentFrame or not parentFrame:IsVisible() then return end

	for i, slotName in ipairs(slots) do
		local slotFrame = buttonsTable[slotName]
		local slotId = GetInventorySlotInfo(slotName)

		if not slotFrame then
			local prefix = (unit == "player") and "MyEquipItem_" or "MyInspectItem_"
			local buttonName = prefix..slotName
			
			slotFrame = CreateFrame("Button", buttonName, parentFrame)
			
			slotFrame:SetWidth(240) 
			slotFrame:SetHeight(18) 
			slotFrame:SetPoint("TOPLEFT", 10, -35 - (i-1)*18)
			
			slotFrame.oid = slotId 
			slotFrame.unit = unit 
			
			slotFrame.text = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			slotFrame.text:SetPoint("LEFT", slotFrame, "LEFT", 5, 0)
			slotFrame.text:SetJustifyH("LEFT")
			
			buttonsTable[slotName] = slotFrame

			slotFrame:SetScript("OnEnter", function()
				this.text:SetFontObject("GameFontHighlightSmall")
				GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
				if ( this.oid and this.unit ) then
					GameTooltip:SetInventoryItem(this.unit, this.oid)
				end
				GameTooltip:Show()
			end)
			
			slotFrame:SetScript("OnLeave", function()
				this.text:SetFontObject("GameFontNormalSmall")
				GameTooltip:Hide()
			end)
			
			slotFrame:RegisterForClicks("LeftButtonUp") 
		end

		local itemLink = GetInventoryItemLink(unit, slotId)

		if itemLink then
			slotFrame.text:SetText(itemLink)
		else
			local emptyText = slotNamesRU[slotName] or slotName
			slotFrame.text:SetText("|cff808080<"..emptyText..">|r")
		end
	end
end

local function CreateBaseFrame(name, parent, titleText)
	local f = CreateFrame("Frame", name, parent)
	f:SetWidth(260)
	f:SetHeight(400)
	f:SetPoint("TOPLEFT", parent, "TOPRIGHT", -30, -10)
	
	f:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	f:SetBackdropColor(0, 0, 0, 0.8)

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetText(titleText)
	title:SetPoint("TOP", 0, -10)
	
	return f
end

local function InitPlayerFrame()
	if Frames.Player then return end
	
	Frames.Player = CreateBaseFrame("MyEquipmentFrame", PaperDollFrame, "Экипировка")
	
	Frames.Player:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	Frames.Player:SetScript("OnEvent", function()
		UpdateUnitGear(Frames.Player, Buttons.Player, "player")
	end)
	
	Frames.Player:SetScript("OnShow", function()
		UpdateUnitGear(Frames.Player, Buttons.Player, "player")
	end)
end

local function InitInspectFrame()
	if not InspectFrame then return end
	if Frames.Inspect then return end

	Frames.Inspect = CreateBaseFrame("MyInspectFrame", InspectFrame, "Осмотр")
	
	Frames.Inspect:RegisterEvent("INSPECT_PAPERDOLL_UPDATE")
	Frames.Inspect:RegisterEvent("UNIT_INVENTORY_CHANGED")
	
	Frames.Inspect:SetScript("OnEvent", function()
		if event == "UNIT_INVENTORY_CHANGED" and arg1 ~= "target" then return end
		UpdateUnitGear(Frames.Inspect, Buttons.Inspect, "target")
	end)

	Frames.Inspect:SetScript("OnShow", function()
		UpdateUnitGear(Frames.Inspect, Buttons.Inspect, "target")
	end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("ADDON_LOADED")

loader:SetScript("OnEvent", function()
	if event == "PLAYER_LOGIN" then
		InitPlayerFrame()
		if IsAddOnLoaded("Blizzard_InspectUI") then
			InitInspectFrame()
		end
	elseif event == "ADDON_LOADED" then
		if arg1 == "Blizzard_InspectUI" then
			InitInspectFrame()
		end
	end
end)

