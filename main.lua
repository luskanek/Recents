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

    items[bag] = {}

    local size = GetContainerNumSlots(bag)
    for slot = 1, size do
        local item = _G['ContainerFrame' .. bag + 1 .. 'Item' .. size - slot + 1]
        local border = _G[item:GetName() .. 'Highlight']
        if border then
            border:SetScript('OnUpdate', nil)
            border:Hide()
            border = nil
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
                        border = CreateFrame('Frame', item:GetName() .. 'Highlight', item)
                        border:SetBackdrop({
                            bgFile = 'Interface\\AddOns\\Recents\\assets\\UI-Icon-QuestBorder'
                        })

                        border:SetPoint('CENTER', item)
                        border:SetWidth(item:GetWidth())
                        border:SetHeight(item:GetHeight())
                        border:EnableMouse(true)
                    end

                    border.glow = true
                    border:SetScript('OnUpdate',
                        function()
                            local _, _, _, a = this:GetBackdropColor()
                            if this.glow then
                                this:SetBackdropColor(1, 1, 1, a + 0.01)
                                if (a >= 0.9) then border.glow = false end

                            else
                                this:SetBackdropColor(1, 1, 1, a - 0.02)
                                if (a <= 0.1) then this.glow = true end
                            end
                        end
                    )

                    border:SetScript('OnEnter',
                        function()
                            this:SetScript('OnUpdate', nil)
                            this:Hide()
                            border = nil
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