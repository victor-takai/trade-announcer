---@diagnostic disable: return-type-mismatch, undefined-field

--- Addon name, namespace
local addonName, addonTable = ...

--- AceAddon local variable
local aceAddon = addonTable.aceAddon

--- AceLocale local variable
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- Local variables
local mainFrame, mainFrameInset
local scrollFrame, scrollBar, editBox
local vButtonsFrame, hButtonsFrame
local settingsButton, firstProfessionButton, secondProfessionButton
local toggleButton, testButton, advertiseButton

--- Settings table
local settings = {
    mainFrame = {
        size = {
            width = 450,
            height = 200,
        },
    },

    defaultButtons = {
        size = {
            width = 50,
            height = 25,
        },
    },

    smallButtons = {
        size = {
            width = 25,
            height = 25,
        },
    },
}

function addonTable:CreateMainFrame()
    mainFrame = CreateFrame("Frame", "TradeAnnouncerMainFrame", UIParent, "ButtonFrameTemplate")

    --- Hide portrait
    ButtonFrameTemplate_HidePortrait(mainFrame)

    -- Hide top tile streaks
    mainFrame.TopTileStreaks:Hide()

    --- Setup title text
    local title = mainFrame.TitleContainer.TitleText
    title:SetText("|cff66bbff" .. addonName .. "|r")

    --- Setup inset
    mainFrameInset = mainFrame.Inset
    mainFrameInset:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 40, -10)
    mainFrameInset:SetPoint("BOTTOMRIGHT", mainFrame, -25, 38)
    mainFrameInset.Bg:SetScript("OnMouseDown", function (_, _)
        editBox:SetFocus()
    end)

    local width = settings.mainFrame.size.width
    local height = settings.mainFrame.size.height

    mainFrame:SetSize(width, height)

    if aceAddon.db.profile.position.x and aceAddon.db.profile.position.y then
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", aceAddon.db.profile.position.x, aceAddon.db.profile.position.y)
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
            aceAddon.db.profile.position.x = cx
            aceAddon.db.profile.position.y = cy
        end
    end)

    mainFrame:SetScript("OnShow", function(this)
        this:SetMovable(true)
    end)

    mainFrame:SetScript("OnHide", function(this)
        this:SetMovable(false)
    end)
end

function addonTable:CreateScrollFrame()
    scrollFrame = CreateFrame("ScrollFrame", "TradeAnnouncerScrollFrame", mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", mainFrameInset, 5, -5)
    scrollFrame:SetPoint("BOTTOMLEFT", mainFrameInset, 5, 5)
    scrollFrame:SetPoint("RIGHT", mainFrame)
    scrollFrame:SetClipsChildren(true)

    scrollBar = scrollFrame.ScrollBar
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -22, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -22, 16)
    scrollBar.Bg = scrollBar:CreateTexture("TradeAnnouncerScrollFrameBg", "BACKGROUND")
    scrollBar.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble")
    scrollBar.Bg:SetHorizTile(true)
    scrollBar.Bg:SetVertTile(true)
    scrollBar.Bg:SetAllPoints(scrollBar)
end

function addonTable:CreateEditBox()
    editBox = CreateFrame("EditBox", "TradeAnnouncerEditBox", scrollFrame)
    editBox:SetSize(mainFrameInset:GetWidth(), mainFrameInset:GetHeight())
    -- editBox.Bg = editBox:CreateTexture(nil, "BACKGROUND")
    -- editBox.Bg:SetAllPoints(editBox)
    -- editBox.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetMultiLine(true)
    editBox:SetHyperlinksEnabled()
    editBox:SetFontObject(GameFontNormal)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(255)
    editBox:SetAltArrowKeyMode(false)

    editBox:SetScript("OnTextChanged", function(this)
        aceAddon.db.profile.trade_text = this:GetText()
    end)

    editBox:SetScript("OnEditFocusGained", function()
        addonTable:OnFocusGained()
    end)

    editBox:SetScript("OnEditFocusLost", function()
        addonTable:OnFocusLost()
    end)

    editBox:SetScript("OnEscapePressed", function()
        addonTable:HideUI()
    end)

    scrollFrame:SetScrollChild(editBox)
end

function addonTable:CreateButtonsFrame()
    vButtonsFrame = CreateFrame("Frame", "TradeAnnouncerVButtonsFrame", mainFrame)
    vButtonsFrame:SetPoint("TOPLEFT", mainFrame.TitleContainer, "BOTTOMLEFT", 10, -6)
    vButtonsFrame:SetPoint("BOTTOMRIGHT", mainFrameInset, "BOTTOMLEFT")

    -- vButtonsFrame.Bg = vButtonsFrame:CreateTexture("TradeAnnouncerVButtonsFrameBg", "BACKGROUND")
    -- vButtonsFrame.Bg:SetAllPoints(vButtonsFrame)
    -- vButtonsFrame.Bg:SetColorTexture(0.2, 0, 0.6, 0.5)

    local icon = "Interface\\Icons\\INV_Misc_Gear_06"
    settingsButton = CreateFrame("Button", "TradeAnnouncerSettingsButton", vButtonsFrame, "UIPanelButtonTemplate")
    settingsButton:SetNormalTexture(icon)
    settingsButton:SetPushedTexture(icon)
    settingsButton:SetSize(settings.smallButtons.size.width, settings.smallButtons.size.height)
    settingsButton:SetPoint("TOP", vButtonsFrame, 0, -5)
    settingsButton:SetPoint("CENTER", vButtonsFrame)
    settingsButton:SetScript("OnClick", function()
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end)
    settingsButton:SetScript("OnEnter", function(this)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["OPEN_SETTINGS"], 1, 1, 1, 0.8)
        GameTooltip:Show()
    end)
    settingsButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self:CreateProfessionButtons(vButtonsFrame, settingsButton)

    hButtonsFrame = CreateFrame("Frame", "TradeAnnouncerHButtonsFrame", mainFrame)
    hButtonsFrame:SetPoint("TOPLEFT", vButtonsFrame, "BOTTOMLEFT")
    hButtonsFrame:SetPoint("BOTTOMLEFT", mainFrame, 0, 5)
    hButtonsFrame:SetPoint("BOTTOMRIGHT", mainFrame, 0, 5)

    -- hButtonsFrame.Bg = hButtonsFrame:CreateTexture("TradeAnnouncerHButtonsFrameBg", "BACKGROUND")
    -- hButtonsFrame.Bg:SetAllPoints(hButtonsFrame)
    -- hButtonsFrame.Bg:SetColorTexture(0.2, 0.6, 0, 0.5)

    testButton = CreateFrame("Button", "TradeAnnouncerTestButton", hButtonsFrame, "UIPanelButtonTemplate")
    testButton:SetText(tostring(L["TEST_BUTTON"]))
    testButton:SetSize(settings.defaultButtons.size.width, settings.defaultButtons.size.height)
    testButton:SetPoint("RIGHT", hButtonsFrame, -5, 0)
    testButton:SetPoint("CENTER", hButtonsFrame)
    testButton:SetScript("OnClick", function()
        print(L["YOUR_MESSAGE"] .. editBox:GetText())
    end)
    testButton:SetScript("OnEnter", function(this)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["SHOW_YOUR_MESSAGE"], 1, 1, 1, 0.8)
        GameTooltip:Show()
    end)
    testButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    advertiseButton = CreateFrame("Button", "TradeAnnouncerAdvertiseButton", hButtonsFrame, "UIPanelButtonTemplate")
    advertiseButton:SetText(tostring(L["ADVERTISE_BUTTON"]))
    advertiseButton:SetSize(settings.defaultButtons.size.width + 35, settings.defaultButtons.size.height)
    advertiseButton:SetPoint("TOPRIGHT", testButton, "TOPLEFT", -5, 0)
    advertiseButton:SetScript("OnEnter", function(this)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(tostring(L["SEND_YOUR_MESSAGE"]), 1, 1, 1, 0.8)
        GameTooltip:Show()
    end)
    advertiseButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    advertiseButton:SetScript("OnClick", function(this)
        addonTable:SendAutoMessage()
    end)

    toggleButton = CreateFrame("Button", "TradeAnnouncerToggleButton", hButtonsFrame, "UIPanelButtonTemplate")
    local toggleText = aceAddon.db.profile.is_on and L["TURN_OFF"] or L["TURN_ON"]
    toggleButton:SetText(tostring(toggleText))
    toggleButton:SetSize(settings.defaultButtons.size.width + 25, settings.defaultButtons.size.height)
    toggleButton:SetPoint("TOPRIGHT", advertiseButton, "TOPLEFT", -5, 0)
    toggleButton:SetScript("OnClick", function(this)
        addonTable:ToggleMessage(this)
    end)
end

function addonTable:CreateProfessionButtons(parentFrame, relativeFrame)
    local firstProfession, secondProfession = GetProfessions()

    if firstProfession then
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(firstProfession)
        firstProfessionButton = self:CreateProfessionButton(
            "TradeAnnouncerFirstProfessionButton",
            name,
            icon,
            skillLine,
            parentFrame,
            relativeFrame
        )
    end
    if secondProfession then
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(secondProfession)
        secondProfessionButton = self:CreateProfessionButton(
            "TradeAnnouncerSecondProfessionButton",
            name,
            icon,
            skillLine,
            parentFrame,
            firstProfessionButton or relativeFrame
        )
    end
end

---@param buttonName string
---@param name string
---@param icon string
---@param skillLineId number
---@param parentFrame Frame
---@param relativeFrame Button
---@return Button button
function addonTable:CreateProfessionButton(buttonName, name, icon, skillLineId, parentFrame, relativeFrame)
    local button = CreateFrame("Button", buttonName, parentFrame, "UIPanelButtonTemplate")
    local width = settings.smallButtons.size.width
    local height = settings.smallButtons.size.height

    button:SetNormalTexture(icon)
    button:SetPushedTexture(icon)
    button:SetSize(width, height)
    button:SetPoint("TOP", relativeFrame, "BOTTOM", 0, -10)
    button:SetPoint("CENTER", parentFrame)

    button:SetScript("OnClick", function()
        local professionLink = self:GetLinkForProfession(skillLineId)
        if professionLink then
            editBox:Insert(professionLink)
        end
    end)

    button:SetScript("OnEnter", function(this)
        local localizedMessage = tostring(L["ADD_PROFESSION"])
        local text = string.gsub(localizedMessage, "#PROFESSION#", name)
        GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText(text, 1, 1, 1, 0.8)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

---@param skillLineId number?
---@return string? link
function addonTable:GetLinkForProfession(skillLineId)
    local link

    if skillLineId then
        C_TradeSkillUI.OpenTradeSkill(skillLineId)
        link = C_TradeSkillUI.GetTradeSkillListLink()
        C_TradeSkillUI.CloseTradeSkill()
    end

    return link
end

---@return Frame mainFrame, EditBox editBox
function addonTable:CreateUI()
    self:CreateMainFrame()
    self:CreateScrollFrame()
    self:CreateEditBox()
    self:CreateButtonsFrame()
    return mainFrame, editBox
end