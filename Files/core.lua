---@diagnostic disable: undefined-global, inject-field, duplicate-set-field, undefined-field, missing-fields, param-type-mismatch

--- Addon name, namespace
local addonName, addonTable = ...

--- AceAddon local variable
local aceAddon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceHook-3.0")
addonTable.aceAddon = aceAddon

--- AceLocale local variable
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

--- Local variables
local mainFrame
local editBox
local updateFrame

local isEditBoxOnFocus = false
local hasLoadedUI = false
local hasLoadedOptions = false

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
        auto_focus_enabled = false, -- Default auto focus
        hide_tooltips = false, -- Default hide tooltips
    },
}

----------------------------------------------------------------------------------------

function aceAddon:OnInitialize()
    --- Setup AceDB
    self.db = LibStub("AceDB-3.0"):New("TradeAnnouncerDB", defaults)

    --- Register slash commands
    self:RegisterChatCommand("ta", "SlashCommand")

    --- Setup invisible frame
    addonTable:SetupUpdateFrame()
end

function aceAddon:OnEnable()
    self:SecureHook("HandleModifiedItemClick", function(link)
        if mainFrame:IsShown() and isEditBoxOnFocus then
            editBox:Insert(link)
        end
    end)
end

function aceAddon:OnDisable()
    self:Unhook("HandleModifiedItemClick")
end

function aceAddon:SlashCommand()
    addonTable:ToggleUI()
end

----------------------------------------------------------------------------------------

--- Creates the UI
function addonTable:SetupUI()
    mainFrame, editBox = self:CreateUI()
    self:CreateMinimapButton()
end

--- Creates interface options
function addonTable:SetupInterfaceOption()
    self:CreateInterfaceOptions()
end

--- Creates invisible frame for tracking time
function addonTable:SetupUpdateFrame()
    updateFrame = CreateFrame("Frame")
    updateFrame:SetSize(1, 1)
    updateFrame:SetFrameStrata("HIGH")
    updateFrame:SetToplevel(true)
    updateFrame:SetMovable(false)
    updateFrame:EnableMouse(false)

    --- Inject fields
    updateFrame.timeSinceLastUpdate = 0
    updateFrame.channelsCheckTotalElapsed = 0
    updateFrame.channelsCheckInterval = 1

    --- Register events
    updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    updateFrame:SetScript("OnEvent", UdateFrameOnEvent)

    --- Register updates
	updateFrame:SetScript("OnUpdate", UpdateFrameOnUpdate)
end

----------------------------------------------------------------------------------------

--- Callback function for onEvent used by updateFrame
function UdateFrameOnEvent(self, event, ...)
    if (not hasLoadedUI and event == "PLAYER_ENTERING_WORLD") then
        print(L["ADDON_LOADED"])
        hasLoadedUI = true
        updateFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        addonTable:SetupUI()
    end
end

--- Callback function for onUpdate used by updateFrame
function UpdateFrameOnUpdate(self, elapsed)
    self.channelsCheckTotalElapsed = self.channelsCheckTotalElapsed + elapsed
    if not hasLoadedOptions and self.channelsCheckTotalElapsed >= self.channelsCheckInterval then
        self.channelsCheckTotalElapsed = 0

        local channels = addonTable:GetJoinedChannels()
        local areChannelsEmpty = true
        for _, _ in pairs(channels) do
            areChannelsEmpty = false
        end

        if (not areChannelsEmpty) then
            addonTable:SetupInterfaceOption()
            hasLoadedOptions = true
        end
    end

	if not aceAddon.db.profile.is_on or MessageQueue.GetNumPendingMessages() > 0 then
        return
    end

	self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
	if self.timeSinceLastUpdate >= aceAddon.db.profile.interval then
        addonTable:SendMessage()
		self.timeSinceLastUpdate = 0
	end
end

----------------------------------------------------------------------------------------

--- Gets all joined channels
function addonTable:GetJoinedChannels()
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
function addonTable:CreateMinimapButton()
    local tradeAnnouncerLDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "data source",
        text = addonName,
        icon = "Interface\\AddOns\\TradeAnnouncer\\Resources\\icon",
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
    icon:Register(addonName, tradeAnnouncerLDB, aceAddon.db.profile.minimap)
end

--- Sends the message
function addonTable:SendMessage()
    if aceAddon.db.profile.chat_type or aceAddon.db.profile.channel_type then
        local message = aceAddon.db.profile.trade_text
        if message ~= "" then
            local chatType = addonTable:GetChatName(aceAddon.db.profile.chat_type)
            local target = aceAddon.db.profile.channel_type
            MessageQueue.SendChatMessage(message, chatType, nil, target)
        end
    else
        print(L["SET_CHAT_CHANNEL"])
    end
end

--- Prints the message
function addonTable:PrintMessage()
    print(L["YOUR_MESSAGE"] .. editBox:GetText())
end

--- Toggles auto message
function addonTable:ToggleMessage(toggleButton)
    if aceAddon.db.profile.chat_type or aceAddon.db.profile.channel_type then
        aceAddon.db.profile.is_on = not aceAddon.db.profile.is_on

        local toggleText = aceAddon.db.profile.is_on and L["TURN_OFF"]or L["TURN_ON"]
        toggleButton:SetText(toggleText)

        local message = aceAddon.db.profile.is_on and L["MESSAGE_TURNED_ON"] or L["MESSAGE_TURNED_OFF"]
        if aceAddon.db.profile.is_on then
            local localizedMessage = tostring(L["MESSAGE_WILL_BE_DISPLAYED"])
            message = message .. string.gsub(localizedMessage, "#INTERVAL#", aceAddon.db.profile.interval)
        end
        print(message)
    else
        print(L["SET_CHAT_CHANNEL"])
    end
end

--- Inserts profession link in the message 
function addonTable:LinkProfession(professionLink)
    editBox:Insert(professionLink)
end

--- Toggles the UI
function addonTable:ToggleUI()
    if mainFrame:IsShown() then
        self:HideUI()
    else
        self:ShowUI()
    end
end

--- Hides the UI
function addonTable:ShowUI()
    local text = aceAddon.db.profile.trade_text
    if text ~= "" and editBox:GetText() == "" then
        editBox:SetText(text)
        editBox:SetCursorPosition(editBox:GetText():len())
    end
    mainFrame:Show()
    if aceAddon.db.profile.auto_focus_enabled then
        editBox:SetFocus()
    end
end

--- Shows the UI
function addonTable:HideUI()
    mainFrame:Hide()
end

--- Focus edit box
function addonTable:FocusEditBox()
    editBox:SetFocus()
end

--- Trigered when EditBox gains focus
function addonTable:OnFocusGained()
    isEditBoxOnFocus = true
end

--- Trigered when EditBox loses focus
function addonTable:OnFocusLost()
    isEditBoxOnFocus = false
end

--- Get chat name based on type
function addonTable:GetChatName(chatType)
    if chatType == 1 then
		return L["CHANNEL"]
	elseif chatType == 2 then
		return L["SAY"]
	elseif chatType == 3 then
		return L["YELL"]
	elseif chatType == 4 then
		return L["PARTY"]
	elseif chatType == 5 then
		return L["RAID"]
	elseif chatType == 6 then
		return L["INSTANCE_CHAT"]
	elseif chatType == 7 then
		return L["BATTLEGROUND"]
    elseif chatType == 8 then
		return L["GUILD"]
    elseif chatType == 9 then
		return L["OFFICER"]
    end
	return nil
end