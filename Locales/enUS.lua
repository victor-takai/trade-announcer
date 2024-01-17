local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)
if not L then return end

local addonNamePrint = "|cff66bbff[" .. addonName .. "]|r "
local version = C_AddOns.GetAddOnMetadata(addonName, "Version")

L["ADDON_LOADED"] = "|cff66bbff" .. addonName .. " " .. version .. "|r" .. " loaded."

L["MINIMAP_LEFT_CLICK"] = "|cff6699ffLeft-click|r to open the addon."
L["MINIMAP_RIGHT_CLICK"] = "|cff6699ffRight-click|r to show settings."

L["TURN_ON"] = "Turn |cff40c040ON|r"
L["TURN_OFF"] = "Turn |cffbf2626OFF|r"

L["MESSAGE_TURNED_ON"] = addonNamePrint .. "Your automatic message was turned |cff40c040ON|r"
L["MESSAGE_TURNED_OFF"] = addonNamePrint .. "Your automatic message was turned |cffbf2626OFF|r"
L["MESSAGE_WILL_BE_DISPLAYED"] = " and will be displayed in #INTERVAL# seconds"

L["SET_CHAT_CHANNEL_FIRST"] = addonNamePrint .. "|cffff2020Please set the chat/channel in the addon's settings in order to turn on|r"

L["TEST_BUTTON"] = "Test"
L["ADVERTISE_BUTTON"] = "Advertise"
L["YOUR_MESSAGE"] = addonNamePrint .. "Your message: "
L["SHOW_YOUR_MESSAGE"] = "Print your |cff6699ffmessage|r"
L["SEND_YOUR_MESSAGE"] = "Send your |cff6699ffmessage|r to the chat"

L["OPEN_SETTINGS"] = "Open |cff6699ffsettings|r page"
L["ADD_PROFESSION"] = "Link |cffFFC125[#PROFESSION#]|r to your message"

L["CHAT_TYPE"] = "Chat type"
L["SET_CHAT_TYPE"] = "Set the chat type"

L["CHANNEL"] = "Channel"
L["SAY"] = "Say"
L["YELL"] = "Yell"
L["PARTY"] = "Party"
L["RAID"] = "Raid"
L["INSTANCE"] = "Instance"
L["BATTLEGROUND"] = "Battlefield"
L["GUILD"] = "Guild"
L["OFFICER"] = "Officer"

L["INTERVAL"] = "Interval (seconds)"