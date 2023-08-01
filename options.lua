local addonName, addon = ...

---@enum Enum.ChannelType
local ChannelType = {
    Say = 1,
    Yell = 2,
    Party = 3,
    Raid = 4,
    Instance = 5,
    Battleground = 6,
    Guild = 7,
    Officer = 8,
}

function addon:CreateInterfaceOptions()
    local panel = CreateFrame("Frame")
    panel.name = addonName

    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName)

    local channelDropDown = self:CreateIntervalDropdown(panel, title, "ChannelDropdown")

    self:CreateIntervalSlider(panel, channelDropDown, "IntervalSlider")

	InterfaceOptions_AddCategory(panel)
end

function addon:CreateIntervalDropdown(parent, reference, name)
    local channels = {}
    for key, value in pairs(ChannelType) do
        channels[value] = key
    end

    local dropDownTitle = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    dropDownTitle:SetPoint("TOPLEFT", reference, "BOTTOMLEFT", 0, -16)
	dropDownTitle:SetText("Channel")
	dropDownTitle:SetJustifyH("LEFT")
	dropDownTitle:SetWidth(250)

    local dropDown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", dropDownTitle, "BOTTOMLEFT", -18, -5)

    UIDropDownMenu_SetWidth(dropDown, 150)
    UIDropDownMenu_SetText(dropDown, "Set the channel")
    UIDropDownMenu_Initialize(dropDown, function()
        local info = UIDropDownMenu_CreateInfo()
        for key, value in pairs(channels) do
            info.text = value
            info.value = key
            info.func = function(self)
                TA.db.profile.channel_value = self.value
                UIDropDownMenu_SetSelectedValue(dropDown, self.value)
                UIDropDownMenu_SetText(dropDown, self:GetText())
            end
            info.checked = value == TA.db.profile.channel_value
            UIDropDownMenu_AddButton(info)
        end
    end)

    local channelValue = TA.db.profile.channel_value
    if channelValue then
        UIDropDownMenu_SetSelectedValue(dropDown, channelValue)
        UIDropDownMenu_SetText(dropDown, channels[channelValue])
    end

    return dropDown
end

function addon:CreateIntervalSlider(parent, reference, name)
    local sliderTitle = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sliderTitle:SetPoint("TOPLEFT", reference, "BOTTOMLEFT", 18, -20)
	sliderTitle:SetText("Interval")
	sliderTitle:SetJustifyH("LEFT")
	sliderTitle:SetWidth(250)

    local sliderValueText = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")

    local slider = CreateFrame("Slider", name , parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", sliderTitle, "BOTTOMLEFT", 0, -5)
    slider:SetWidth(160)
	slider:SetMinMaxValues(10, 60)
	slider:SetValue(30)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetOrientation("HORIZONTAL")

    _G[slider:GetName() .. "Low"]:SetText("10s")
	_G[slider:GetName() .. "High"]:SetText("60s")
    -- _G[slider:GetName() .. "Text"]:SetText("Interval")

	slider:SetScript("OnValueChanged", function(self, value, userInput)
        TA.db.profile.interval = value
        sliderValueText:SetText("|cffffcc00" .. value .. "s|r")
	end)

    sliderValueText:SetPoint("CENTER", slider, 0, -10)
	sliderValueText:SetText("|cffffcc00" .. TA.db.profile.interval .. "s|r")
	sliderValueText:SetJustifyH("CENTER")
	sliderValueText:SetWidth(32)

    return slider
end
