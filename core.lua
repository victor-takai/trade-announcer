--- Addon name, namespace
local addonName, addon = ...

--- Variables for UI
local mainFrame
local editBox
local pixelFrame

--- AceAddon reference
TA = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceHook-3.0")

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
        interval = 30, -- Default time interval
        chat_type = 1, -- Default chat
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
    print("Secure Hooked 'HandleModifiedItemClick' Script")
    self:SecureHook("HandleModifiedItemClick", function(link)
        editBox:Insert(link)
    end)
end

function TA:OnDisable()
    print("Unhooked 'HandleModifiedItemClick' Script")
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
    pixelFrame = CreateFrame("Frame")
    pixelFrame:SetFrameStrata("HIGH")
    pixelFrame:SetToplevel(true)
    pixelFrame:SetMovable(false)
    pixelFrame:EnableMouse(false)

    pixelFrame.timeSinceLastUpdate = 0
	pixelFrame:SetScript("OnUpdate", OnUpdate)
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

-- Creates the minimap button
function addon:CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "data source",
        text = addonName,
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ToggleUI()
            elseif button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory("TradeAnnouncer")
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

-- Toggles the UI
function addon:ToggleUI()
    if mainFrame:IsShown() then
        self:HideUI()
    else
        self:ShowUI()
    end
end

-- Hides the UI
function addon:ShowUI()
    local text = TA.db.profile.trade_text
    if text ~= "" and editBox:GetText() == "" then
        editBox:SetText(text)
        editBox:SetCursorPosition(editBox:GetText():len())
    end
    mainFrame:Show()
    editBox:SetFocus()
end

-- Shows the UI
function addon:HideUI()
    mainFrame:Hide()
end

----------------------------------------------------------------------------------------

---@param channelNumber string
---@return string|nil chatType, number|nil target
function GetChannel(channelNumber)
	if channelNumber == 1 then
		return "SAY", nil
	elseif channelNumber == 2 then
		return "YELL", nil
	elseif channelNumber == 3 then
		return "PARTY", nil
	elseif channelNumber == 4 then
		return "RAID", nil
	elseif channelNumber == 5 then
		return "INSTANCE_CHAT", nil
	elseif channelNumber == 6 then
		return "BATTLEGROUND", nil
    elseif channelNumber == 7 then
		return "GUILD", nil
    elseif channelNumber == 8 then
		return "OFFICER", nil
	elseif channelNumber == 9 then
		return "CHANNEL", 2 -- Trade
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
            local chatType, target = GetChannel(Ta.db.profile.channel_value)
            MessageQueue.SendChatMessage(message, chatType, nil, target)
        end
		self.timeSinceLastUpdate = 0
	end
end