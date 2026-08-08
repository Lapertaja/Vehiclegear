lib.versionCheck('Lapertaja/Vehiclegear')

local function getTrunk(plate)
    return exports.ox_inventory:GetInventory('trunk' .. plate, false)
end

local function tableContains(item)
    if not item then return false end
    for _, v in pairs(Config.AuthorizedItems) do
        if v == item then
            return true
        end
    end
    return false
end

local function isPlayerCop(source)
    if not Config.Authorizedjobs or #Config.Authorizedjobs == 0 then
        return true
    end

    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX and ESX.GetPlayerFromId(source)
        if xPlayer then
            for _, job in ipairs(Config.Authorizedjobs) do
                if xPlayer.job.name == job then return true end
            end
            return false
        end
    elseif GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore and QBCore.Functions.GetPlayer(source)
        if Player then
            for _, job in ipairs(Config.Authorizedjobs) do
                if Player.PlayerData.job.name == job then return true end
            end
            return false
        end
    elseif GetResourceState('ox_core') == 'started' then
        local player = Ox and Ox.GetPlayer(source)
        if player then
            for _, job in ipairs(Config.Authorizedjobs) do
                if player.getGroup(job) then return true end
            end
            return false
        end
    end

    return true
end

local function isAllowedVehicle(netId)
    if not Config.VehicleRestricted then return true end
    if not netId then return false end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local model = GetEntityModel(vehicle)
    for _, v in ipairs(Config.allowedVehicles) do
        if joaat(v.name) == model then
            return true
        end
    end
    return false
end

local function checkDistance(source, netId)
    if not netId then return false end
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local playerCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(vehicle)
    return #(playerCoords - vehCoords) <= 10.0
end

lib.callback.register('vehiclegear:isItemInTrunk', function(source, plate, itemName)
    if not itemName or itemName == '' then return true end
    if type(itemName) ~= 'string' then return false end

    local trunk = getTrunk(plate)
    if not trunk then return false end

    local itemCount = exports.ox_inventory:GetItemCount(trunk, itemName)
    return itemCount > 0
end)

RegisterNetEvent('vehiclegear:removeItem', function(itemName, plate, netId)
    local source = source
    if not itemName or itemName == '' or not plate or plate == '' then return end

    if Config.RequireItems and not tableContains(itemName) then return end
    if not isAllowedVehicle(netId) then return end
    if not isPlayerCop(source) then return end
    if not checkDistance(source, netId) then return end

    local trunk = getTrunk(plate)
    if not trunk then return end

    exports.ox_inventory:RemoveItem(trunk, itemName, 1)
end)

RegisterNetEvent('vehiclegear:addItem', function(itemName, plate, netId)
    local source = source
    if not itemName or itemName == '' or not plate or plate == '' then return end

    if Config.RequireItems and not tableContains(itemName) then return end
    if not isAllowedVehicle(netId) then return end
    if not isPlayerCop(source) then return end
    if not checkDistance(source, netId) then return end

    local trunk = getTrunk(plate)
    if not trunk then return end

    exports.ox_inventory:AddItem(trunk, itemName, 1)
end)

