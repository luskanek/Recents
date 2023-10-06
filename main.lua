local _G = getfenv(0)

local items = {}

-- upvalues
local CreateFrame = CreateFrame
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetItemInfo = GetItemInfo

local strfind = string.find

local tonumber = tonumber

local insert = table.insert
local sizeof = table.getn

local function GetItems()
    for bag = 0, 4 do
        items[bag] = {}

        local size = GetContainerNumSlots(bag)
        for slot = 1, size do
            local _, count = GetContainerItemInfo(bag, slot)
            if count then
                local link = GetContainerItemLink(bag, slot)
                local _, _, id = strfind(link, 'item:(%d+):(%d*):(%d*):(%d*)')
                local name = GetItemInfo(tonumber(id))

                insert(items[bag], name)
            end
        end
    end
end

local _ContainerFrame_OnHide = ContainerFrame_OnHide
function ContainerFrame_OnHide()
    _ContainerFrame_OnHide()

    local bag = this:GetID()

    for i = 1, sizeof(items[bag]) do
        items[bag][i] = nil
    end

    local size = GetContainerNumSlots(bag)
    for slot = 1, size do
        local item = _G['ContainerFrame' .. bag + 1 .. 'Item' .. size - slot + 1]
        local border = _G[item:GetName() .. 'Highlight']
        if border then
            border:Hide()
        end
        
        local _, count = GetContainerItemInfo(bag, slot)
        if count then
            local link = GetContainerItemLink(bag, slot)
            local _, _, id  = strfind(link, 'item:(%d+):(%d*):(%d*):(%d*)')
            local name = GetItemInfo(tonumber(id))

            insert(items[bag], name)
        end
    end
end

local _ContainerFrame_OnShow = ContainerFrame_OnShow
function ContainerFrame_OnShow()
	_ContainerFrame_OnShow()

    local bag = this:GetID()

    if sizeof(items[bag]) > 0 then
        local size = GetContainerNumSlots(bag)
        for slot = 1, size do
            local item = _G['ContainerFrame' .. bag + 1 .. 'Item' .. size - slot + 1]
            local _, count = GetContainerItemInfo(bag, slot)
            if count then
                local link = GetContainerItemLink(bag, slot)
                local _, _, id = string.find(link, 'item:(%d+):(%d*):(%d*):(%d*)')
                local name = GetItemInfo(tonumber(id))

                local new = true
                for _, old in pairs(items[bag]) do
                    if old == name then
                        new = false
                        break
                    end
                end

                if new then
                    local border = _G[item:GetName() .. 'Highlight']
                    if not border then
                        border = CreateFrame('Model', item:GetName() .. 'Highlight', item)
                        border:SetModel('Interface\\Buttons\\UI-AutoCastButton.mdx')
                        border:SetScale(1.4)
                        border:SetAlpha(0.3)
                        border:SetAllPoints()
                        border:EnableMouse(true)
                    end

                    border:SetScript('OnEnter',
                        function()
                            this:Hide()
                        end
                    )
                end
            end
        end
    end
end

local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_ENTERING_WORLD')
handler:SetScript('OnEvent', GetItems)