---@diagnostic disable: inject-field, param-type-mismatch

--- Addon name, namespace
local addonName, addonTable = ...

--- AceAddon local variable
local aceAddon = addonTable.aceAddon

--- AceLocale local variable
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

function addonTable:CreateInterfaceOptions()
    local panel = CreateFrame("Frame")
    panel.name = addonName

    local title = self:CreateTitle(panel)
    local dropDownFrame = self:CreateChatTypeDropdown(panel, title)
    local intervalFrame = self:CreateIntervalSlider(panel, dropDownFrame)
    local autoFocusBoxFrame = self:CreateAutoFocusCheckBox(panel, intervalFrame)
    local hideTooltipsFrame = self:CreateHideTooltipsCheckBox(panel, autoFocusBoxFrame)
    self:CreateHideMinimapButtonCheckBox(panel, hideTooltipsFrame)

    if InterfaceOptions_AddCategory then
	    InterfaceOptions_AddCategory(panel)
    else
        local category, layout = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
        category.ID = panel.name
        Settings.RegisterAddOnCategory(category)
    end
end

function addonTable:CreateTitle(panel)
    local title = panel:CreateFontString("TradeAnnouncerSettingsTitle", "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)

    local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
    if version then
        title:SetText(addonName .. " |cffffff99" .. version .. "|r")
    else
        title:SetText(addonName)
    end

    return title
end

function addonTable:CreateChatTypeDropdown(parentFrame, referenceFrame)
    local chatTypes = {}
    for key, value in pairs(ChatType) do
        chatTypes[value] = L[string.upper(key)]
    end

    local joinedChannels = self:GetJoinedChannels()

    local frame = CreateFrame("Frame", "TradeAnnouncerChatTypeDropdownFrame", parentFrame)
    frame:SetPoint("TOPLEFT", referenceFrame, "BOTTOMLEFT", 0, -16)

    -- frame.Bg = frame:CreateTexture(nil, "BACKGROUND")
    -- frame.Bg:SetAllPoints(frame)
    -- frame.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    local title = frame:CreateFontString("TradeAnnouncerChatTypeDropdownTitle", "ARTWORK", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", frame)
	title:SetText(tostring(L["CHAT_TYPE"]))
    -- title:SetTextColor(1, 1, 1, 1)
    title:SetJustifyH("LEFT")

    local dropDown = CreateFrame("Frame", "TradeAnnouncerChatTypeDropown", frame, "UIDropDownMenuTemplate")
    dropDown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -18, -5)

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
                        aceAddon.db.profile.chat_type = self.value
                        aceAddon.db.profile.channel_type = nil
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
                info.checked = value == aceAddon.db.profile.chat_type
                UIDropDownMenu_AddButton(info, level)
            end

        elseif menuList == "Channels" then

            for _, channel in pairs(joinedChannels) do
                if not channel.isDisabled then
                    info.text = channel.name
                    info.value = channel.id
                    info.func = function(self)
                        aceAddon.db.profile.chat_type = 1
                        aceAddon.db.profile.channel_type = self.value
                        UIDropDownMenu_SetText(dropDown, chatTypes[1] .. ": " .. self:GetText())
                        CloseDropDownMenus()
                    end
                    info.checked = channel.id == aceAddon.db.profile.channel_type
                    UIDropDownMenu_AddButton(info, level)
                end
            end

        end
    end)

    --- Loads last selected chat type
    local chatType = aceAddon.db.profile.chat_type
    local channelType = aceAddon.db.profile.channel_type

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

    local width = max(dropDown:GetWidth(), title:GetWidth())
    local height = dropDown:GetHeight() + title:GetHeight()
    frame:SetSize(width, height)

    return frame
end

function addonTable:CreateIntervalSlider(parentFrame, referenceFrame)
    local frame = CreateFrame("Frame", "TradeAnnouncerIntervalSliderFrame", parentFrame)
    frame:SetPoint("TOPLEFT", referenceFrame, "BOTTOMLEFT", 0, -16)

    -- frame.Bg = frame:CreateTexture(nil, "BACKGROUND")
    -- frame.Bg:SetAllPoints(frame)
    -- frame.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    local title = frame:CreateFontString("TradeAnnouncerIntervalSliderTitle", "ARTWORK", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", frame)
	title:SetText(tostring(L["INTERVAL"]))
    -- title:SetTextColor(1, 1, 1, 1)
	title:SetJustifyH("LEFT")
	title:SetWidth(200)

    local sliderValueText = frame:CreateFontString("TradeAnnouncerIntervalSliderText", "ARTWORK", "GameFontHighlightSmall")

    local slider = CreateFrame("Slider", "TradeAnnouncerIntervalSlider" , frame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    slider:SetWidth(200)
	slider:SetMinMaxValues(10, 120)
	slider:SetValue(30)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetOrientation("HORIZONTAL")

    _G[slider:GetName() .. "Low"]:SetText("10s")
	_G[slider:GetName() .. "High"]:SetText("120s")

	slider:SetScript("OnValueChanged", function(_, value)
        aceAddon.db.profile.interval = value
        sliderValueText:SetText(value .. "s")
	end)

    sliderValueText:SetPoint("CENTER", slider, 0, -10)
	sliderValueText:SetText(aceAddon.db.profile.interval .. "s")
	sliderValueText:SetJustifyH("CENTER")
	sliderValueText:SetWidth(100)

    local width = max(slider:GetWidth(), title:GetWidth())
    local height = slider:GetHeight() + title:GetHeight() + sliderValueText:GetHeight()
    frame:SetSize(width, height)

    return frame
end

function addonTable:CreateAutoFocusCheckBox(parentFrame, referenceFrame)
    local frame = CreateFrame("Frame", "TradeAnnouncerAutoFocusFrame", parentFrame)
    frame:SetPoint("TOPLEFT", referenceFrame, "BOTTOMLEFT", 0, -24)

    -- frame.Bg = frame:CreateTexture(nil, "BACKGROUND")
    -- frame.Bg:SetAllPoints(frame)
    -- frame.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    local checkBox = CreateFrame("CheckButton", "TradeAnnouncerAutoFocusCheckBox", frame, "UICheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", frame, -5, 5)
    checkBox:SetChecked(aceAddon.db.profile.auto_focus_enabled)
    checkBox:SetScript("OnClick", function()
        aceAddon.db.profile.auto_focus_enabled = not aceAddon.db.profile.auto_focus_enabled
    end)

    local text = frame:CreateFontString("TradeAnnouncerAutoFocusCheckboxText", "ARTWORK", "GameFontNormalSmall")
    text:SetPoint("LEFT", checkBox, "RIGHT")
	text:SetText(tostring(L["AUTO_FOCUS"]))
    text:SetTextColor(1, 1, 1, 1)
	text:SetJustifyH("LEFT")
	text:SetWidth(200)

    local width = max(checkBox:GetWidth(), text:GetWidth())
    local height = checkBox:GetHeight() - 11
    frame:SetSize(width, height)

    return frame
end

function addonTable:CreateHideTooltipsCheckBox(parentFrame, referenceFrame)
    local frame = CreateFrame("Frame", "TradeAnnouncerHideTooltipsFrame", parentFrame)
    frame:SetPoint("TOPLEFT", referenceFrame, "BOTTOMLEFT", 0, -16)

    -- frame.Bg = frame:CreateTexture(nil, "BACKGROUND")
    -- frame.Bg:SetAllPoints(frame)
    -- frame.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    local checkBox = CreateFrame("CheckButton", "TradeAnnouncerHideTooltipsCheckBox", frame, "UICheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", frame, -5, 5)
    checkBox:SetChecked(aceAddon.db.profile.hide_tooltips)
    checkBox:SetScript("OnClick", function()
        aceAddon.db.profile.hide_tooltips = not aceAddon.db.profile.hide_tooltips
    end)

    local text = frame:CreateFontString("TradeAnnouncerHideTooltipsCheckboxText", "ARTWORK", "GameFontNormalSmall")
    text:SetPoint("LEFT", checkBox, "RIGHT")
	text:SetText(tostring(L["HIDE_TOOLTIPS"]))
    text:SetTextColor(1, 1, 1, 1)
	text:SetJustifyH("LEFT")
	text:SetWidth(200)

    local width = max(checkBox:GetWidth(), text:GetWidth())
    local height = checkBox:GetHeight() - 11
    frame:SetSize(width, height)

    return frame
end

function addonTable:CreateHideMinimapButtonCheckBox(parentFrame, referenceFrame)
    local frame = CreateFrame("Frame", "TradeAnnouncerHideMinimapButtonFrame", parentFrame)
    frame:SetPoint("TOPLEFT", referenceFrame, "BOTTOMLEFT", 0, -16)

    -- frame.Bg = frame:CreateTexture(nil, "BACKGROUND")
    -- frame.Bg:SetAllPoints(frame)
    -- frame.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    local checkBox = CreateFrame("CheckButton", "TradeAnnouncerHideMinimapButtonCheckBox", frame, "UICheckButtonTemplate")
    checkBox:SetPoint("TOPLEFT", frame, -5, 5)
    checkBox:SetChecked(aceAddon.db.profile.hide_tooltips)
    checkBox:SetScript("OnClick", function()
        aceAddon.db.profile.hide_minimap_button = checkBox:GetChecked()
        addonTable:ToggleMinimapButton()
    end)

    local text = frame:CreateFontString("TradeAnnouncerHideMinimapButtonCheckboxText", "ARTWORK", "GameFontNormalSmall")
    text:SetPoint("LEFT", checkBox, "RIGHT")
	text:SetText(tostring(L["HIDE_MINIMAP_BUTTON"]))
    text:SetTextColor(1, 1, 1, 1)
	text:SetJustifyH("LEFT")
	text:SetWidth(200)

    local width = max(checkBox:GetWidth(), text:GetWidth())
    local height = checkBox:GetHeight() - 11
    frame:SetSize(width, height)

    return frame
end
