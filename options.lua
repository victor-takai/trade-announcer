--- Addon name, namespace
local addonName, addon = ...

--- Locale
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- @enum Enum.ChatType
local ChatType = {
    Channel = 1,
    Say = 2,
    Yell = 3,
    Party = 4,
    Raid = 5,
    Instance = 6,
    Battleground = 7,
    Guild = 8,
    Officer = 9,
}

function addon:CreateInterfaceOptions()
    ---@class Frame
    local panel = CreateFrame("Frame")
    panel.name = addonName

    local title = self:CreateTitle(panel)
    local channelDropDown = self:CreateIntervalDropdown(panel, title, "TA_Channel_Dropdown")
    local intervalSlider = self:CreateIntervalSlider(panel, channelDropDown, "TA_Interval_Slider")

	InterfaceOptions_AddCategory(panel)

    return title, channelDropDown, intervalSlider
end

function addon:CreateTitle(panel)
    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
    if version then
        title:SetText(addonName .. " |cffffff99" .. version .. "|r")
    else
        title:SetText(addonName)
    end

    return title
end

function addon:CreateIntervalDropdown(parent, reference, name)
    local chatTypes = {}
    for key, value in pairs(ChatType) do
        chatTypes[value] = key
    end

    local joinedChannels = self:GetJoinedChannels()

    local dropDownTitle = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    dropDownTitle:SetPoint("TOPLEFT", reference, "BOTTOMLEFT", 0, -16)
	dropDownTitle:SetText(L["CHAT_TYPE"])
    dropDownTitle:SetJustifyH("LEFT")
	dropDownTitle:SetWidth(200)

    local dropDown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", dropDownTitle, "BOTTOMLEFT", -18, -5)

    UIDropDownMenu_SetWidth(dropDown, 200)
    UIDropDownMenu_SetText(dropDown, L["SET_CHAT_TYPE"])
    UIDropDownMenu_JustifyText(dropDown, "LEFT")

    UIDropDownMenu_Initialize(dropDown, function(_, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        if (level or 1) == 1 then

            for value, text in pairs(chatTypes) do
                info.text = text
                info.value = value
                info.func = function(self)
                    if self.value ~= 1 then
                        TA.db.profile.chat_type = self.value
                        TA.db.profile.channel_type = nil
                        UIDropDownMenu_SetText(dropDown, self:GetText())
                    end
                end
                if value == 1 then
                    info.menuList = "Channels"
                    info.hasArrow = true
                else
                    info.menuList = nil
                    info.hasArrow = false
                end
                info.checked = value == TA.db.profile.chat_type
                UIDropDownMenu_AddButton(info, level)
            end

        elseif menuList == "Channels" then

            for _, channel in pairs(joinedChannels) do
                if not channel.isDisabled then
                    info.text = channel.name
                    info.value = channel.id
                    info.func = function(self)
                        TA.db.profile.chat_type = 1
                        TA.db.profile.channel_type = self.value
                        UIDropDownMenu_SetText(dropDown, chatTypes[1] .. ": " .. self:GetText())
                        CloseDropDownMenus()
                    end
                    info.checked = channel.id == TA.db.profile.channel_type
                    UIDropDownMenu_AddButton(info, level)
                end
            end

        end
    end)

    --- Loads last selected chat type
    local chatType = TA.db.profile.chat_type
    local channelType = TA.db.profile.channel_type

    if chatType then
        local channelName

        if chatType == 1 then
            for _, channel in pairs(joinedChannels) do
                if channel.id == channelType then
                    channelName = channel.name
                    break
                end
            end
        end

        if channelName then
            UIDropDownMenu_SetText(dropDown, chatTypes[chatType] .. ": " .. channelName)
        else
            UIDropDownMenu_SetText(dropDown, chatTypes[chatType])
        end
    end

    return dropDown
end

function addon:CreateIntervalSlider(parent, reference, name)
    local sliderTitle = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sliderTitle:SetPoint("TOPLEFT", reference, "BOTTOMLEFT", 18, -16)
	sliderTitle:SetText(L["INTERVAL"])
	sliderTitle:SetJustifyH("LEFT")
	sliderTitle:SetWidth(200)

    local sliderValueText = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")

    local slider = CreateFrame("Slider", name , parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", sliderTitle, "BOTTOMLEFT", 0, -5)
    slider:SetWidth(200)
	slider:SetMinMaxValues(10, 120)
	slider:SetValue(30)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetOrientation("HORIZONTAL")

    _G[slider:GetName() .. "Low"]:SetText("10s")
	_G[slider:GetName() .. "High"]:SetText("120s")

	slider:SetScript("OnValueChanged", function(_, value)
        TA.db.profile.interval = value
        sliderValueText:SetText("|cffffcc00" .. value .. "s|r")
	end)

    sliderValueText:SetPoint("CENTER", slider, 0, -10)
	sliderValueText:SetText("|cffffcc00" .. TA.db.profile.interval .. "s|r")
	sliderValueText:SetJustifyH("CENTER")
	sliderValueText:SetWidth(100)

    return slider
end
