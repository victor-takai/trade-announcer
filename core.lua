--- Addon name, namespace
local addonName, addon = ...

--- Locale
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- Variables
local mainFrame
local editBox
local updateFrame
local isEditBoxOnFocus = false
local hasLoadedUI = false
local hasLoadedOptions = false

--- AceAddon reference
---@class AceAddon
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
        channel_type = nil, -- Default channel
    },
}

----------------------------------------------------------------------------------------

function TA:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TradeAnnouncerDB", defaults)
    --- Register slash commands
    self:RegisterChatCommand("ta", "SlashCommand")

    addon:SetupUpdateFrame()
end

function TA:OnEnable()
    self:SecureHook("HandleModifiedItemClick", function(link)
        if mainFrame:IsShown() and isEditBoxOnFocus then
            editBox:Insert(link)
        end
    end)
end

function TA:OnDisable()
    self:Unhook("HandleModifiedItemClick")
end

function TA:SlashCommand()
    addon:ToggleUI()
end

----------------------------------------------------------------------------------------

--- Creates the UI
function addon:SetupUI()
    mainFrame, editBox = self:CreateUI()
end

--- Creates interface options
function addon:SetupInterfaceOption()
    self:CreateInterfaceOptions()
end

--- Creates invisible frame for tracking time
function addon:SetupUpdateFrame()
    ---@class Frame
    updateFrame = CreateFrame("Frame")
    updateFrame:SetFrameStrata("HIGH")
    updateFrame:SetToplevel(true)
    updateFrame:SetMovable(false)
    updateFrame:EnableMouse(false)

    --- Register events
    updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    updateFrame:SetScript("OnEvent", OnEvent)

    --- Register updates
    updateFrame.timeSinceLastUpdate = 0
    updateFrame.channelsCheckTotalElapsed = 0
    updateFrame.channelsCheckInterval = 1
	updateFrame:SetScript("OnUpdate", OnUpdate)
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
    local tradeAnnouncerLDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "data source",
        text = addonName,
        icon = "Interface\\AddOns\\TradeAnnouncer\\icon",
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ToggleUI()
            elseif button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory(addonName)
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(addonName)
            tooltip:AddLine(L["MINIMAP_LEFT_CLICK"], 1, 1, 1)
            tooltip:AddLine(L["MINIMAP_RIGHT_CLICK"], 1, 1, 1)
        end,
    })

    local icon = LibStub("LibDBIcon-1.0")
    icon:Register(addonName, tradeAnnouncerLDB, TA.db.profile.minimap)
end

--- Toggles auto message
function addon:ToggleMessage(toggleButton)
    if TA.db.profile.chat_type or TA.db.profile.channel_type then
        TA.db.profile.is_on = not TA.db.profile.is_on

        local toggleText = TA.db.profile.is_on and L["TURN_OFF"]or L["TURN_ON"]
        toggleButton:SetText(toggleText)

        local message = TA.db.profile.is_on and L["MESSAGE_TURNED_ON"] or L["MESSAGE_TURNED_OFF"]
        if TA.db.profile.is_on then
            local localizedMessage = tostring(L["MESSAGE_WILL_BE_DISPLAYED"])
            message = message .. string.gsub(localizedMessage, "#INTERVAL#", TA.db.profile.interval)
        end
        print(message)
    else
        print(L["SET_CHAT_CHANNEL_FIRST"])
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
    self.channelsCheckTotalElapsed = self.channelsCheckTotalElapsed + elapsed
    if not hasLoadedOptions and self.channelsCheckTotalElapsed >= self.channelsCheckInterval then
        self.channelsCheckTotalElapsed = 0

        local channels = addon:GetJoinedChannels()
        local areChannelsEmpty = true
        for _, _ in pairs(channels) do
            areChannelsEmpty = false
        end

        if (not areChannelsEmpty) then
            addon:SetupInterfaceOption()
            hasLoadedOptions = true
        end
    end

	if not TA.db.profile.is_on or MessageQueue.GetNumPendingMessages() > 0 then
        return
    end

	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
    local message = TA.db.profile.trade_text

	if self.timeSinceLastUpdate >= TA.db.profile.interval then
        if message ~= "" then
            local chatType = addon:GetChatName(TA.db.profile.chat_type)
            local target = TA.db.profile.channel_type
            MessageQueue.SendChatMessage(message, chatType, nil, target)
        end
		self.timeSinceLastUpdate = 0
	end
end

function OnEvent(self, event, ...)
    if (not hasLoadedUI and event == "PLAYER_ENTERING_WORLD") then
        print(L["ADDON_LOADED"])
        hasLoadedUI = true
        updateFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        addon:SetupUI()
    end
end