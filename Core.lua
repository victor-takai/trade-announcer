-- Core.lua

--- Addon name, namespace
local addonName, addon = ...

-- Variables for UI
local mainFrame
local editBox

--- AceAddon reference
TA = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")

-- Defaults for AceDB
local defaults = {
    profile = {
        minimap = {
            hide = false,
        },
        trade_text = "",
    },
}

-- AceAddon methods
----------------------------------------------------------------------------------------

function TA:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeAnnouncerDB", defaults)
    self:RegisterChatCommand("ta", "SlashCommand")

    addon:SetupAddon()
end

function TA:OnEnable()
	-- Called when the addon is enabled
end

function TA:OnDisable()
	-- Called when the addon is disabled
end

function TA:SlashCommand()
    addon:ShowUI()
end

----------------------------------------------------------------------------------------

--- Creates the UI
function addon:SetupAddon()
    self:CreateMinimapButton()
    mainFrame = self:CreateMainFrame()
    self:CreateMainFrameLabel(mainFrame)
    local scrollFrame = self:CreateScrollFrame(mainFrame)
    editBox = self:CreateEditBox(scrollFrame)
    local saveButton = self:CreateSaveButton(mainFrame)
    self:CreateTestButton(mainFrame, editBox)
    self:CreateProfessionButtons(mainFrame, saveButton, editBox)
end

-- Creates the minimap button
function addon:CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("TradeAnnouncer", {
        type = "data source",
        text = "TradeAnnouncer", -- Tooltip
        icon = "Interface\\Icons\\INV_Misc_QuestionMark", -- Icon path
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ShowUI()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("TradeAnnouncer")
            tooltip:AddLine("Left-click to open input box.", 1, 1, 1, 1)
        end,
    })

    LibStub("LibDBIcon-1.0"):Register("TradeAnnouncer", ldb, TA.db.profile.minimap)
end

-- Shows the UI
function addon:ShowUI()
    editBox:SetText(TA.db.profile.trade_text or "")
    editBox:SetCursorPosition(editBox:GetText():len())
    mainFrame:Show()
    editBox:SetFocus()
end

-- Hides the UI
function addon:HideUI()
    TA.db.profile.trade_text = editBox:GetText()
    mainFrame:Hide()
end

-- Handles modified click on a item
hooksecurefunc("HandleModifiedItemClick", function(link)
    -- if itemLocation and itemLocation:IsBagAndSlot() and editBox:IsShown() then
        editBox:Insert(link)
    -- end
end)