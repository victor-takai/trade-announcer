---@diagnostic disable: return-type-mismatch, undefined-field, param-type-mismatch

--- Addon name, namespace
local addonName, addonTable = ...

--- AceAddon local variable
local aceAddon = addonTable.aceAddon

--- AceLocale local variable
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- Local variables
local mainFrame, mainFrameInset
local scrollFrame, scrollBar, editBox
local hButtonsFrame
local firstLinkButton, secondLinkButton
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
    mainFrameInset:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 12, -10)
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
    hButtonsFrame = CreateFrame("Frame", "TradeAnnouncerHButtonsFrame", mainFrame)
    hButtonsFrame:SetPoint("TOPLEFT", mainFrameInset, "BOTTOMLEFT")
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
        if not aceAddon.db.profile.hide_tooltips then
            GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
            GameTooltip:SetText(L["SHOW_YOUR_MESSAGE"], 1, 1, 1, 1)
            GameTooltip:Show()
        end
    end)

    testButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    advertiseButton = CreateFrame("Button", "TradeAnnouncerAdvertiseButton", hButtonsFrame, "UIPanelButtonTemplate")
    advertiseButton:SetText(tostring(L["ADVERTISE_BUTTON"]))
    advertiseButton:SetSize(settings.defaultButtons.size.width + 35, settings.defaultButtons.size.height)
    advertiseButton:SetPoint("TOPRIGHT", testButton, "TOPLEFT", -5, 0)

    advertiseButton:SetScript("OnEnter", function(this)
        if not aceAddon.db.profile.hide_tooltips then
            GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
            GameTooltip:SetText(tostring(L["SEND_YOUR_MESSAGE"]), 1, 1, 1, 1)
            GameTooltip:Show()
        end
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

    self:CreateProfessionButtons(hButtonsFrame)
end

function addonTable:CreateProfessionButtons(parentFrame)
    local firstProfession, secondProfession = GetProfessions()
    local number = 1

    if firstProfession then
        local name, _, _, _, _, _, skillLine = GetProfessionInfo(firstProfession)
        firstLinkButton = self:CreateProfessionButton(
            "TradeAnnouncerFirstProfessionButton",
            name,
            number,
            skillLine,
            parentFrame,
            nil
        )
        number = number + 1
    end
    if secondProfession then
        local name, _, _, _, _, _, skillLine = GetProfessionInfo(secondProfession)
        secondLinkButton = self:CreateProfessionButton(
            "TradeAnnouncerSecondProfessionButton",
            name,
            number,
            skillLine,
            parentFrame,
            firstLinkButton
        )
    end
end

--- @param buttonName string
--- @param name string
--- @param number number
--- @param skillLineId number
--- @param parentFrame Frame
--- @param relativeFrame Button
--- @return Button button
function addonTable:CreateProfessionButton(buttonName, name, number, skillLineId, parentFrame, relativeFrame)
    local button = CreateFrame("Button", buttonName, parentFrame, "UIPanelButtonTemplate")

    button:SetText("Link #" .. tostring(number))
    button:SetSize(settings.defaultButtons.size.width + 15, settings.defaultButtons.size.height)
    if relativeFrame == nil then
        button:SetPoint("LEFT", parentFrame)
        button:SetPoint("CENTER", parentFrame)
    else
        button:SetPoint("TOPLEFT", relativeFrame, "TOPRIGHT", 5, 0)
    end

    button:SetScript("OnClick", function()
        local professionLink = self:GetLinkForProfession(skillLineId)
        if professionLink then
            editBox:Insert(professionLink)
        end
    end)

    button:SetScript("OnEnter", function(this)
        if not aceAddon.db.profile.hide_tooltips then
            local localizedMessage = tostring(L["ADD_PROFESSION"])
            local text = string.gsub(localizedMessage, "#PROFESSION#", name)
            GameTooltip:SetOwner(this or UIParent, "ANCHOR_BOTTOM")
            GameTooltip:SetText(text, 1, 1, 1, 1)
            GameTooltip:Show()
        end
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

--- @param skillLineId number?
--- @return string? link
function addonTable:GetLinkForProfession(skillLineId)
    local link

    if skillLineId then
        C_TradeSkillUI.OpenTradeSkill(skillLineId)
        link = C_TradeSkillUI.GetTradeSkillListLink()
        C_TradeSkillUI.CloseTradeSkill()
    end

    return link
end

--- @return Frame mainFrame, EditBox editBox
function addonTable:CreateUI()
    self:CreateMainFrame()
    self:CreateScrollFrame()
    self:CreateEditBox()
    self:CreateButtonsFrame()
    return mainFrame, editBox
end