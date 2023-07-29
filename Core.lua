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
        position = {
            x = nil,
            y = nil,
        },
        minimap = {
            hide = false,
        },
        trade_text = "",
        is_on = false,
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
    addon:ToggleUI()
end

----------------------------------------------------------------------------------------

--- Creates the UI
function addon:SetupAddon()
    self:CreateMinimapButton()
    mainFrame = self:CreateMainFrame()
    self:CreateMainFrameLabel(mainFrame)
    local scrollFrame = self:CreateScrollFrame(mainFrame)
    editBox = self:CreateEditBox(scrollFrame)
    local toggleButton = self:CreateToggleButton(mainFrame)
    self:CreateTestButton(mainFrame, editBox)
    self:CreateProfessionButtons(mainFrame, toggleButton, editBox)
end

-- Creates the minimap button
function addon:CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "data source",
        text = addonName,
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ToggleUI()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(addonName)
            tooltip:AddLine("Left-click to open input box.", 1, 1, 1, 1)
        end,
    })

    LibStub("LibDBIcon-1.0"):Register(addonName, ldb, TA.db.profile.minimap)
end

-- Toggles the UI
function addon:ToggleUI()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        editBox:SetCursorPosition(editBox:GetText():len())
        mainFrame:Show()
        editBox:SetFocus()
    end
end

-- Handles modified click on a item
hooksecurefunc("HandleModifiedItemClick", function(link)
    -- if itemLocation and itemLocation:IsBagAndSlot() and editBox:IsShown() then
        editBox:Insert(link)
    -- end
end)