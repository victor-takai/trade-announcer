-- UIBuilder.lua

local _, addon = ...

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

    button = {
        size = {
            width = 50,
            height = 25,
        },
    },

    profession = {
        button = {
            size = {
                width = 20,
                height = 20,
            },
            padding = 5
        },
    },
}

---@return Frame|UIPanelDialogTemplate mainFrame
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

    mainFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)

    mainFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            local x, y = self:GetCenter()
            local px, py = self:GetParent():GetCenter()
            local cx, cy = x-px, y-py
            TA.db.profile.position.x = cx
            TA.db.profile.position.y = cy
        end
    end)

    mainFrame:SetScript("OnShow", function(self)
        self:SetMovable(true)
    end)

    mainFrame:SetScript("OnHide", function(self)
        self:SetMovable(false)
    end)

    return mainFrame
end

---@param mainFrame Frame|UIPanelDialogTemplate
---@return FontString label
function addon:CreateLabel(mainFrame)
    local label = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    label:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", settings.title.padding.x, settings.title.padding.y)
    label:SetJustifyH("LEFT")
    label:SetText("TradeAnnouncer")
    label:SetTextColor(0, 1, 0, 0.75)

    return label
end

---@param mainFrame Frame|UIPanelDialogTemplate
---@return ScrollFrame|UIPanelScrollFrameTemplate scrollFrame
function addon:CreateScrollFrame(mainFrame)
    local width = settings.main.size.width - (settings.main.padding * 2) - settings.scroll.barSpacing - settings.scroll.adjustSpacing
    local height = settings.main.size.height - settings.button.size.height - (settings.main.padding * 3) - settings.title.spacing
    local pointX = settings.main.padding + settings.scroll.adjustSpacing
    local pointY = -(settings.main.padding + settings.title.spacing)

    local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width, height)
    scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", pointX, pointY)

    return scrollFrame
end

---@param scrollFrame ScrollFrame|UIPanelScrollFrameTemplate
---@return EditBox editBox
function addon:CreateEditBox(scrollFrame)
    local editBox = CreateFrame("EditBox", nil, scrollFrame)

    editBox:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())
    editBox:SetPoint("TOPLEFT", scrollFrame)
    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetMultiLine(true)
    editBox:SetHyperlinksEnabled()
    editBox:SetFontObject(GameFontNormal)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(255)
    editBox:SetAltArrowKeyMode(false)

    editBox:SetScript("OnTextChanged", function(self)
        TA.db.profile.trade_text = self:GetText()
        -- print(TA.db.profile.trade_text)
    end)

    editBox:SetScript("OnEscapePressed", function()
        addon:HideUI()
    end)

    scrollFrame:SetScrollChild(editBox)

    return editBox
end

---@param mainFrame Frame|UIPanelDialogTemplate
---@return Button|UIPanelButtonTemplate toggleButton
function addon:CreateToggleButton(mainFrame)
    local toggleButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    local width = settings.button.size.width + 35
    local height = settings.button.size.height

    local text = addon:GetToggleText(TA.db.profile.is_on)
    toggleButton:SetText("Turn " .. text)
    toggleButton:SetSize(width, height)
    toggleButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", settings.main.padding, settings.main.padding)

    toggleButton:SetScript("OnClick", function(self)
        TA.db.profile.is_on = not TA.db.profile.is_on
        local text = addon:GetToggleText(TA.db.profile.is_on)
        local inversedText = addon:GetToggleText(not TA.db.profile.is_on)
        self:SetText("Turn " .. text)
        print("Your trade message was turned " .. inversedText)
    end)

    return toggleButton
end

---@param mainFrame Frame|UIPanelDialogTemplate
---@param editBox EditBox
---@return Button|UIPanelButtonTemplate testButton
function addon:CreateTestButton(mainFrame, editBox)
    local testButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    local width = settings.button.size.width
    local height = settings.button.size.height

    testButton:SetText("Test")
    testButton:SetSize(width, height)
    testButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -settings.main.padding + 3, settings.main.padding)

    testButton:SetScript("OnClick", function()
        print("Your trade message: " .. editBox:GetText())
    end)

    testButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Shows your trade text as print message", 1, 1, 1, 0.5)
        GameTooltip:Show()
    end)

    testButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return testButton
end

---@param mainFrame Frame|UIPanelDialogTemplate
---@param saveButton Button|UIPanelButtonTemplate
---@param editBox EditBox
---@return Button|UIPanelButtonTemplate firstProfessionButton, Button|UIPanelButtonTemplate secondProfessionButton
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

---@param name string
---@param icon string
---@param skillLineId number
---@param mainFrame Frame|UIPanelDialogTemplate
---@param editBox EditBox
---@param relativeButton Button|UIPanelButtonTemplate
---@return Button|UIPanelButtonTemplate button
function addon:CreateProfessionButton(name, icon, skillLineId, mainFrame, editBox, relativeButton)
    local width = settings.profession.button.size.width
    local height = settings.profession.button.size.height
    local padding = settings.profession.button.padding
    local button = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")

    button:SetNormalTexture(icon)
    button:SetPushedTexture(icon)
    button:SetHighlightTexture(icon)
    button:SetSize(width, height)
    button:SetPoint("RIGHT", relativeButton, "RIGHT", width + padding, 0)

    button:SetScript("OnClick", function()
        editBox:Insert(self:GetLinkForProfession(skillLineId))
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Adds |cffFFC125[" .. name .. "]|r to trade text", 1, 1, 1, 0.5)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

---@param skillLineId number?
---@return string? link
function addon:GetLinkForProfession(skillLineId)
    local link

    if skillLineId then
        C_TradeSkillUI.OpenTradeSkill(skillLineId)
        link = C_TradeSkillUI.GetTradeSkillListLink()
        C_TradeSkillUI.CloseTradeSkill()
    end

    return link
end

function addon:CreateUI()
    self:CreateMinimapButton()
    local mainFrame = self:CreateMainFrame()
    self:CreateLabel(mainFrame)
    local scrollFrame = self:CreateScrollFrame(mainFrame)
    local editBox = self:CreateEditBox(scrollFrame)
    local toggleButton = self:CreateToggleButton(mainFrame)
    self:CreateTestButton(mainFrame, editBox)
    self:CreateProfessionButtons(mainFrame, toggleButton, editBox)

    return mainFrame, editBox
end