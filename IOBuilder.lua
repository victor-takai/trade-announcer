-- IOBuilder.lua

local addonName, addon = ...

---@enum Enum.ChannelType
local ChannelType = {
    Say = 1,
    Yell = 2,
    Party = 3,
    Raid = 4,
    Instance = 5,
    Battleground = 6,
    Guild = 7,
}

function addon:CreateInterfaceOptions()
    local panel = CreateFrame("Frame")
    panel.name = addonName

    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName)

    local values = {}
    for key, value in pairs(ChannelType) do
        values[value] = key
    end

    local dropDown = self:CreateDropdown(panel, "ChannelDropdown", values)
    dropDown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -18, -16)

	InterfaceOptions_AddCategory(panel)
end

function addon:CreateDropdown(parent, name, values)
    local dropDown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint("CENTER")

    UIDropDownMenu_SetWidth(dropDown, 150)
    UIDropDownMenu_SetText(dropDown, "Set the channel")
    -- UIDropDownMenu_JustifyText(dropDown, "LEFT")
    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for key, value in pairs(values) do
            info.text = value
            info.value = key
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropDown
end
