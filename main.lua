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

local function GetContainerItems(container)
    items[container] = {}

    for slot = 1, GetContainerNumSlots(container) do
        local _, count = GetContainerItemInfo(container, slot)
        if count then
            local link = GetContainerItemLink(container, slot)
            local _, _, id = strfind(link, 'item:(%d+):(%d*):(%d*):(%d*)')
            local name = GetItemInfo(tonumber(id))

            insert(items[container], name)
        end
    end
end

local _ContainerFrame_OnHide = ContainerFrame_OnHide
function ContainerFrame_OnHide()
    _ContainerFrame_OnHide()

    GetContainerItems(this:GetID())
end

local _ContainerFrame_OnShow = ContainerFrame_OnShow
function ContainerFrame_OnShow()
	_ContainerFrame_OnShow()

    local container = this:GetID()

    if items[container] and sizeof(items[container]) > 0 then
        local size = GetContainerNumSlots(container)
        for slot = 1, size do
            local item = _G['ContainerFrame' .. container + 1 .. 'Item' .. size - slot + 1]
            local _, count = GetContainerItemInfo(container, slot)
            if count then
                local link = GetContainerItemLink(container, slot)
                local _, _, id = string.find(link, 'item:(%d+):(%d*):(%d*):(%d*)')
                local name = GetItemInfo(tonumber(id))

                local new = true
                for _, old in pairs(items[container]) do
                    if old == name then
                        new = false
                        break
                    end
                end

                if new then
                    local highlight = _G[item:GetName() .. 'Highlight']
                    if not highlight then
                        highlight = item:CreateTexture(item:GetName() .. 'Highlight', 'OVERLAY')
                        highlight:SetTexture('Interface\\BUTTONS\\CheckButtonGlow')
                        highlight:SetPoint('TOPLEFT', item, -16, 16)
                        highlight:SetPoint('BOTTOMRIGHT', item, 16, -16)

                        local script = item:GetScript('OnEnter')
                        item:SetScript('OnEnter',
                            function()
                                script()
                                
                                UIFrameFlashStop(highlight)
                            end
                        )
                    end

                    UIFrameFlash(highlight, 0.5, 0.5, 10, false)
                end
            end
        end
    end
end

local function HandleEvent()
    for container = 0, 4 do
        GetContainerItems(container)
    end
end

local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_ENTERING_WORLD')
handler:SetScript('OnEvent', HandleEvent)