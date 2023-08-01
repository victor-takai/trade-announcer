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

    local channels = {}
    for key, value in pairs(ChannelType) do
        channels[value] = key
    end

    local channelDropDown = self:CreateDropdown(panel, "ChannelDropdown", channels)
    channelDropDown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -18, -16)

    local channelValue = TA.db.profile.channel_value
    if channelValue then
        UIDropDownMenu_SetSelectedValue(channelDropDown, channelValue)
        UIDropDownMenu_SetText(channelDropDown, channels[channelValue])
    end

    local slider = CreateFrame("Slider", "DurationSlider" , panel, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", channelDropDown, "BOTTOMLEFT", 18, -16)
    slider:SetWidth(160)
	slider:SetMinMaxValues(10, 60)
	slider:SetValue(30)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetOrientation("HORIZONTAL")

    _G[slider:GetName() .. "Low"]:SetText("10s")
	_G[slider:GetName() .. "High"]:SetText("60s")

	slider:SetScript("OnValueChanged", function(self, value, userInput)
        TA.db.profile.rate = value
	end)

	InterfaceOptions_AddCategory(panel)
end

function addon:CreateDropdown(parent, name, values)
    local dropDown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint("CENTER")

    UIDropDownMenu_SetWidth(dropDown, 150)
    UIDropDownMenu_SetText(dropDown, "Set the channel")
    UIDropDownMenu_Initialize(dropDown, function()
        local info = UIDropDownMenu_CreateInfo()
        for key, value in pairs(values) do
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

    return dropDown
end
