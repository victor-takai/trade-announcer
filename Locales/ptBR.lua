local addonName = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ptBR")
if not L then return end

local addonNamePrint = "|cff66bbff[" .. addonName .. "]|r "
local version = C_AddOns.GetAddOnMetadata(addonName, "Version")

L["ADDON_LOADED"] = "|cff66bbff" .. addonName .. " " .. version .. "|r" .. " carregado."

L["MINIMAP_LEFT_CLICK"] = "|cff6699ffBotão-esquerdo|r para abrir o addon."
L["MINIMAP_RIGHT_CLICK"] = "|cff6699ffBotão-direito|r para exibir as configurações."

L["TURN_ON"] = "|cff40c040LIGAR|r"
L["TURN_OFF"] = "|cffbf2626DESLIGAR|r"

L["MESSAGE_TURNED_ON"] = addonNamePrint .. "Sua mensagem automática está |cff40c040LIGADA|r"
L["MESSAGE_TURNED_OFF"] = addonNamePrint .. "Sua mensagem automática está |cffbf2626DESLIGADA|r"
L["MESSAGE_WILL_BE_DISPLAYED"] = " e será exibida em #INTERVAL# segundos"

L["SET_CHAT_CHANNEL"] = addonNamePrint .. "|cffff2020Configure o chat/canal nas configurações do addon|r"

L["TEST_BUTTON"] = "Testar"
L["ADVERTISE_BUTTON"] = "Anunciar"
L["YOUR_MESSAGE"] = addonNamePrint .. "Sua mensagem: \n"
L["SHOW_YOUR_MESSAGE"] = "Exibe sua |cff6699ffmensagem|r"
L["SEND_YOUR_MESSAGE"] = "Envia sua |cff6699ffmensagem|r no chat"

L["OPEN_SETTINGS"] = "Abre a página de |cff6699ffconfigurações|r"
L["ADD_PROFESSION"] = "Vincula |cffFFC125[#PROFESSION#]|r à sua mensagem"

L["CHAT_TYPE"] = "Tipo do chat"
L["SET_CHAT_TYPE"] = "Selecione o chat"

L["CHANNEL"] = "Canal"
L["SAY"] = "Dizer"
L["YELL"] = "Gritar"
L["PARTY"] = "Grupo"
L["RAID"] = "Raide"
L["INSTANCE"] = "Instância"
L["BATTLEGROUND"] = "Campo de Batalha"
L["GUILD"] = "Guilda"
L["OFFICER"] = "Oficial"

L["INTERVAL"] = "Intervalo (segundos)"