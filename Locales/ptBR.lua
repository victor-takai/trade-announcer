local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ptBR")
if not L then return end

local addonNamePrint = "|cff66bbff[" .. addonName .. "]|r "
local version = GetAddOnMetadata(addonName, "Version")

L["ADDON_LOADED"] = "|cff66bbff" .. addonName .. " " .. version .. "|r" .. " carregado."

L["MINIMAP_LEFT_CLICK"] = "|cff6699ffBotão-esquerdo|r para abrir o addon."
L["MINIMAP_RIGHT_CLICK"] = "|cff6699ffBotão-direito|r para exibir as configurações."

L["TURN_ON"] = "|cff40c040LIGAR|r"
L["TURN_OFF"] = "|cffbf2626DESLIGAR|r"

L["MESSAGE_TURNED_ON"] = addonNamePrint .. "Sua mensagem automática está |cff40c040LIGADA|r"
L["MESSAGE_TURNED_OFF"] = addonNamePrint .. "Sua mensagem automática está |cffbf2626DESLIGADA|r"
L["MESSAGE_WILL_BE_DISPLAYED"] = " e será exibida em #INTERVAL# segundos"

L["SET_CHAT_CHANNEL_FIRST"] = addonNamePrint .. "|cffff2020Primeiro configure o chat/canal nas configurações do addon para poder ligá-lo|r"

L["TEST_BUTTON"] = "Testar"
L["YOUR_TRADE_MESSAGE"] = addonNamePrint .. "Sua mensagem: \n"
L["SHOWS_YOUR_TRADE_MESSAGE"] = "Exibe sua mensagem automática usando o comando print"

L["OPENS_SETTINGS"] = "Abre a página de configurações"
L["ADDS_PROFESSION"] = "Adiciona |cffFFC125[#PROFESSION#]|r à mensagem"

L["CHAT_TYPE"] = "Tipo do chat"
L["SET_CHAT_TYPE"] = "Selecione o chat"

L["INTERVAL"] = "Intervalo (segundos)"