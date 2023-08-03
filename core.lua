--- Addon name, namespace
local addonName, addon = ...

--- Locale
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- Variables
local mainFrame
local editBox
local updateFrame
local isEditBoxOnFocus = false

--- AceAddon reference
TA = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceHook-3.0")

--- Defaults for AceDB
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
        interval = 30, -- Default time interval
        chat_type = nil, -- Default chat
        channel_type = nil -- Default channel
    },
}

----------------------------------------------------------------------------------------

function TA:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeAnnouncerDB", defaults)
    self:RegisterChatCommand("ta", "SlashCommand")

    addon:SetupUI()
    addon:SetupOnUpdate()
end

function TA:OnEnable()
    -- print("Secure Hooked 'HandleModifiedItemClick' Script")
    self:SecureHook("HandleModifiedItemClick", function(link)
        if mainFrame:IsShown() and isEditBoxOnFocus then
            editBox:Insert(link)
        end
    end)
end

function TA:OnDisable()
    -- print("Unhooked 'HandleModifiedItemClick' Script")
    self:Unhook("HandleModifiedItemClick")
end

function TA:SlashCommand()
    addon:ToggleUI()
end

----------------------------------------------------------------------------------------

--- Creates the UI
function addon:SetupUI()
    mainFrame, editBox = self:CreateUI()
    self:CreateInterfaceOptions()
end

--- Creates invisible frame for tracking time
function addon:SetupOnUpdate()
    updateFrame = CreateFrame("Frame")
    updateFrame:SetFrameStrata("HIGH")
    updateFrame:SetToplevel(true)
    updateFrame:SetMovable(false)
    updateFrame:EnableMouse(false)

    updateFrame.timeSinceLastUpdate = 0
	updateFrame:SetScript("OnUpdate", OnUpdate)
end

-- Generates colored text based on boolean
function addon:GetToggleText(isOn)
    return isOn and "|cffbf2626OFF|r" or "|cff40c040ON|r"
end

--- Gets all joined channels
function addon:GetJoinedChannels()
    local channels = { }
    local channelList = { GetChannelList() }
    for i = 1, #channelList, 3 do
        table.insert(channels, {
            id = channelList[i],
            name = channelList[i+1],
            isDisabled = channelList[i+2],
        })
    end
    return channels
end

--- Creates the minimap button
function addon:CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "data source",
        text = addonName,
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ToggleUI()
            elseif button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(addonName)
            tooltip:AddLine("|cff6699ffLeft-click|r to open input box.", 1, 1, 1)
            tooltip:AddLine("|cff6699ffRight-click|r to show options.", 1, 1, 1)
        end,
    })

    LibStub("LibDBIcon-1.0"):Register(addonName, ldb, TA.db.profile.minimap)
end

--- Toggles auto message
function addon:ToggleMessage(toggleButton)
    if TA.db.profile.chat_type or TA.db.profile.channel_type then
        TA.db.profile.is_on = not TA.db.profile.is_on
        local text = self:GetToggleText(TA.db.profile.is_on)
        local inversedText = self:GetToggleText(not TA.db.profile.is_on)
        toggleButton:SetText("Turn " .. text)
        local message = "Your auto trade message was turned " .. inversedText
        if TA.db.profile.is_on then
            message = message .. " and will be displayed in " .. TA.db.profile.interval .. " seconds."
        end
        print(message)
    else
        print("Please set a chat/channel first in the addon's settings.")
    end
end

--- Toggles the UI
function addon:ToggleUI()
    if mainFrame:IsShown() then
        self:HideUI()
    else
        self:ShowUI()
    end
end

--- Hides the UI
function addon:ShowUI()
    local text = TA.db.profile.trade_text
    if text ~= "" and editBox:GetText() == "" then
        editBox:SetText(text)
        editBox:SetCursorPosition(editBox:GetText():len())
    end
    mainFrame:Show()
    editBox:SetFocus()
end

--- Shows the UI
function addon:HideUI()
    mainFrame:Hide()
end

--- Trigered when EditBox gains focus
function addon:OnFocusGained()
    isEditBoxOnFocus = true
end

--- Trigered when EditBox loses focus
function addon:OnFocusLost()
    isEditBoxOnFocus = false
end

----------------------------------------------------------------------------------------

function addon:GetChatName(chatType)
    if chatType == 1 then
		return "CHANNEL"
	elseif chatType == 2 then
		return "SAY"
	elseif chatType == 3 then
		return "YELL"
	elseif chatType == 4 then
		return "PARTY"
	elseif chatType == 5 then
		return "RAID"
	elseif chatType == 6 then
		return "INSTANCE_CHAT"
	elseif chatType == 7 then
		return "BATTLEGROUND"
    elseif chatType == 8 then
		return "GUILD"
    elseif chatType == 9 then
		return "OFFICER"
    end
	return nil
end

function OnUpdate(self, elapsed)
	if not TA.db.profile.is_on or MessageQueue.GetNumPendingMessages() > 0 then
        return
    end

	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
    local message = TA.db.profile.trade_text

	if self.timeSinceLastUpdate > TA.db.profile.interval then
        if message ~= "" then
            local chatType = addon:GetChatName(TA.db.profile.chat_type)
            local target = TA.db.profile.channel_type
            MessageQueue.SendChatMessage(message, chatType, nil, target)
        end
		self.timeSinceLastUpdate = 0
	end
end