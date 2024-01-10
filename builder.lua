--- Addon name, namespace
local addonName, addon = ...

--- Locale
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- Settings
local settings = {
    main = {
        size = {
            width = 450,
            height = 175,
        },
        padding = 10,
    },

    scroll = {
        adjustSpacing = 8,
        barSpacing = 20,
    },

    title = {
        padding = {
            x = 15,
            y = -9,
        },
        spacing = 25
    },

    defaultButtons = {
        size = {
            width = 50,
            height = 25,
        },
    },

    smallButtons = {
        size = {
            width = 20,
            height = 20,
        },
        padding = 5,
    },
}

--- @return Frame|UIPanelDialogTemplate mainFrame
function addon:CreateMainFrame()
    local mainFrame = CreateFrame("Frame", nil, UIParent, "UIPanelDialogTemplate")
    local width = settings.main.size.width
    local height = settings.main.size.height

    mainFrame:SetSize(width, height)

    if TA.db.profile.position.x and TA.db.profile.position.y then
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", TA.db.profile.position.x, TA.db.profile.position.y)
    else
        mainFrame:SetPoint("CENTER", UIParent)
    end

    mainFrame:SetToplevel(true)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:Hide()

    mainFrame:SetScript("OnMouseDown", function(this, button)
        if button == "LeftButton" then
            this:StartMoving()
        end
    end)

    mainFrame:SetScript("OnMouseUp", function(this, button)
        if button == "LeftButton" then
            this:StopMovingOrSizing()
            local x, y = this:GetCenter()
            local px, py = this:GetParent():GetCenter()
            local cx, cy = x-px, y-py
            TA.db.profile.position.x = cx
            TA.db.profile.position.y = cy
        end
    end)

    mainFrame:SetScript("OnShow", function(this)
        this:SetMovable(true)
    end)

    mainFrame:SetScript("OnHide", function(this)
        this:SetMovable(false)
    end)

    return mainFrame
end

--- @param mainFrame Frame|UIPanelDialogTemplate
--- @return FontString label
function addon:CreateLabel(mainFrame)
    local label = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", mainFrame:GetName(), "TOPLEFT", settings.title.padding.x, settings.title.padding.y)
    label:SetJustifyH("LEFT")
    label:SetText("|cff66bbff" .. addonName .. "|r")
    -- label:SetTextColor(0, 1, 0, 0.75)

    return label
end

--- @param mainFrame Frame|UIPanelDialogTemplate
--- @return ScrollFrame|UIPanelScrollFrameTemplate scrollFrame
function addon:CreateScrollFrame(mainFrame)
    local width = settings.main.size.width - (settings.main.padding * 2) - settings.scroll.barSpacing - settings.scroll.adjustSpacing
    local height = settings.main.size.height - settings.defaultButtons.size.height - (settings.main.padding * 3) - settings.title.spacing
    local pointX = settings.main.padding + settings.scroll.adjustSpacing
    local pointY = -(settings.main.padding + settings.title.spacing)

    local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width, height)
    scrollFrame:SetPoint("TOPLEFT", mainFrame:GetName(), "TOPLEFT", pointX, pointY)

    return scrollFrame
end

--- @param scrollFrame ScrollFrame|UIPanelScrollFrameTemplate
--- @return EditBox editBox
function addon:CreateEditBox(scrollFrame)
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())
    editBox:SetPoint("TOPLEFT", scrollFrame:GetName())
    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetMultiLine(true)
    editBox:SetHyperlinksEnabled()
    editBox:SetFontObject(GameFontNormal)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(255)
    editBox:SetAltArrowKeyMode(false)

    editBox:SetScript("OnTextChanged", function(this)
        TA.db.profile.trade_text = this:GetText()
    end)

    editBox:SetScript("OnEditFocusGained", function()
        addon:OnFocusGained()
    end)

    editBox:SetScript("OnEditFocusLost", function()
        addon:OnFocusLost()
    end)

    editBox:SetScript("OnEscapePressed", function()
        addon:HideUI()
    end)

    scrollFrame:SetScrollChild(editBox)

    return editBox
end

--- @param mainFrame Frame|UIPanelDialogTemplate
--- @return Button|UIPanelButtonTemplate toggleButton
function addon:CreateToggleButton(mainFrame)
    local toggleButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    local width = settings.defaultButtons.size.width + 35
    local height = settings.defaultButtons.size.height

    local toggleText = TA.db.profile.is_on and L["TURN_OFF"] or L["TURN_ON"]
    toggleButton:SetText(tostring(toggleText))
    toggleButton:SetSize(width, height)
    toggleButton:SetPoint("BOTTOMLEFT", mainFrame:GetName(), "BOTTOMLEFT", settings.main.padding, settings.main.padding)

    toggleButton:SetScript("OnClick", function(this)
        addon:ToggleMessage(this)
    end)

    return toggleButton
end

--- @param mainFrame Frame|UIPanelDialogTemplate
--- @param editBox EditBox
--- @return Button|UIPanelButtonTemplate testButton
function addon:CreateTestButton(mainFrame, editBox)
    local width = settings.defaultButtons.size.width
    local height = settings.defaultButtons.size.height

    local testButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    local localizedText = tostring(L["TEST_BUTTON"])
    testButton:SetText(localizedText)
    testButton:SetSize(width, height)
    testButton:SetPoint("BOTTOMRIGHT", mainFrame:GetName(), "BOTTOMRIGHT", -settings.main.padding + 3, settings.main.padding)

    testButton:SetScript("OnClick", function()
        print(L["YOUR_TRADE_MESSAGE"] .. editBox:GetText())
    end)

    testButton:SetScript("OnEnter", function(this)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["SHOWS_YOUR_TRADE_MESSAGE"], 1, 1, 1, 0.5)
        GameTooltip:Show()
    end)

    testButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return testButton
end

--- @param mainFrame Frame|UIPanelDialogTemplate
--- @param relativeButton Button|UIPanelButtonTemplate
--- @return Button|UIPanelButtonTemplate settingsButton
function addon:CreateSettingsButton(mainFrame, relativeButton)
    local width = settings.smallButtons.size.width
    local height = settings.smallButtons.size.height
    local padding = settings.smallButtons.padding
    local icon = "Interface\\Icons\\INV_Misc_Gear_06"

    local settingsButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    settingsButton:SetNormalTexture(icon)
    settingsButton:SetPushedTexture(icon)
    settingsButton:SetSize(width, height)
    settingsButton:SetPoint("RIGHT", relativeButton:GetName(), "LEFT", -padding, 0)

    settingsButton:SetScript("OnClick", function()
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end)

    settingsButton:SetScript("OnEnter", function(this)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["OPENS_SETTINGS"], 1, 1, 1, 0.5)
        GameTooltip:Show()
    end)

    settingsButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return settingsButton
end

--- @param mainFrame Frame|UIPanelDialogTemplate
--- @param saveButton Button|UIPanelButtonTemplate
--- @param editBox EditBox
--- @return Button|UIPanelButtonTemplate firstProfessionButton, Button|UIPanelButtonTemplate secondProfessionButton
function addon:CreateProfessionButtons(mainFrame, saveButton, editBox)
    local firstProfession, secondProfession = GetProfessions()
    local firstProfessionButton, secondProfessionButton

    if firstProfession then
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(firstProfession)
        firstProfessionButton = self:CreateProfessionButton(
            name,
            icon,
            skillLine,
            mainFrame,
            editBox,
            saveButton
        )
    end
    if secondProfession then
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(secondProfession)
        secondProfessionButton = self:CreateProfessionButton(
            name,
            icon,
            skillLine,
            mainFrame,
            editBox,
            firstProfessionButton or saveButton
        )
    end

    return firstProfessionButton, secondProfessionButton
end

--- @param name string
--- @param icon string
--- @param skillLineId number
--- @param mainFrame Frame|UIPanelDialogTemplate
--- @param editBox EditBox
--- @param relativeButton Button|UIPanelButtonTemplate
--- @return Button|UIPanelButtonTemplate button
function addon:CreateProfessionButton(name, icon, skillLineId, mainFrame, editBox, relativeButton)
    local button = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    local width = settings.smallButtons.size.width
    local height = settings.smallButtons.size.height
    local padding = settings.smallButtons.padding

    button:SetNormalTexture(icon)
    button:SetPushedTexture(icon)
    button:SetSize(width, height)
    button:SetPoint("RIGHT", relativeButton:GetName(), "RIGHT", width + padding, 0)

    button:SetScript("OnClick", function()
        local professionLink = self:GetLinkForProfession(skillLineId)
        if professionLink then
            editBox:Insert(professionLink)
        end
    end)

    button:SetScript("OnEnter", function(this)
        local localizedMessage = tostring(L["ADDS_PROFESSION"])
        local text = string.gsub(localizedMessage, "#PROFESSION#", name)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(text, 1, 1, 1, 0.5)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

--- @param skillLineId number?
--- @return string? link
function addon:GetLinkForProfession(skillLineId)
    local link

    if skillLineId then
        C_TradeSkillUI.OpenTradeSkill(skillLineId)
        link = C_TradeSkillUI.GetTradeSkillListLink()
        C_TradeSkillUI.CloseTradeSkill()
    end

    return link
end

--- @return Frame|UIPanelDialogTemplate mainFrame, EditBox editBox
function addon:CreateUI()
    self:CreateMinimapButton()
    local mainFrame = self:CreateMainFrame()
    self:CreateLabel(mainFrame)
    local scrollFrame = self:CreateScrollFrame(mainFrame)
    local editBox = self:CreateEditBox(scrollFrame)
    local toggleButton = self:CreateToggleButton(mainFrame)
    local testButton = self:CreateTestButton(mainFrame, editBox)
    self:CreateSettingsButton(mainFrame, testButton)
    self:CreateProfessionButtons(mainFrame, toggleButton, editBox)

    return mainFrame, editBox
end