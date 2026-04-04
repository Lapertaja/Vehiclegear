lib.versionCheck('Lapertaja/Vehiclegear')

local trunk

local function getTrunk(plate)
    trunk = exports.ox_inventory:GetInventory('trunk' .. plate, false)
end

---@return boolean itemIsInTrunk
lib.callback.register('vehiclegear:isItemInTrunk', function(source, plate, itemName)
    if not itemName or itemName == '' then return true end

    getTrunk(plate)
    if not trunk then return false end

    local itemCount = exports.ox_inventory:GetItemCount(trunk, itemName)
    return itemCount > 0
end)

RegisterNetEvent('vehiclegear:removeItem', function(itemName, plate)
    if itemName and itemName ~= '' then
        getTrunk(plate)
        if not trunk then return end

        exports.ox_inventory:RemoveItem(trunk, itemName, 1)
    end
end)

RegisterNetEvent('vehiclegear:addItem', function(itemName, plate)
    if itemName and itemName ~= '' then
        getTrunk(plate)
        if not trunk then return end

        exports.ox_inventory:AddItem(trunk, itemName, 1)
    end
end)
