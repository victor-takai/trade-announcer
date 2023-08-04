local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
if not L then return end

local addonNamePrint = "|cff66bbff[" .. addonName .. "]|r "

L["MINIMAP_LEFT_CLICK"] = "|cff6699ffLeft-click|r to open the addon."
L["MINIMAP_RIGHT_CLICK"] = "|cff6699ffRight-click|r to show settings."

L["TURN_ON"] = "Turn |cff40c040ON|r"
L["TURN_OFF"] = "Turn |cffbf2626OFF|r"

L["MESSAGE_TURNED_ON"] = addonNamePrint .. "Your auto trade message was turned |cff40c040ON|r"
L["MESSAGE_TURNED_OFF"] = addonNamePrint .. "Your auto trade message was turned |cffbf2626OFF|r"
L["MESSAGE_WILL_BE_DISPLAYED"] = " and will be displayed in #INTERVAL# seconds"

L["SET_CHAT_CHANNEL_FIRST"] = addonNamePrint .. "|cffff2020Please set the chat/channel in the addon's settings in order to turn on|r"

L["TEST_BUTTON"] = "Test"
L["YOUR_TRADE_MESSAGE"] = addonNamePrint .. "Your message: "
L["SHOWS_YOUR_TRADE_MESSAGE"] = "Shows your trade text as print message"

L["OPENS_SETTINGS"] = "Opens settings page"
L["ADDS_PROFESSION"] = "Adds |cffFFC125[#PROFESSION#]|r to trade text"

L["CHAT_TYPE"] = "Chat type"
L["SET_CHAT_TYPE"] = "Set the chat type"

L["INTERVAL"] = "Interval (seconds)"