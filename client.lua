local originalVest = nil
local originalHelmet = nil
local hasTakenHelmet = false
local BProofTaken = false
local ESX = nil
local QBCore = nil

if Config.RequireJob then
    CreateThread(function()
        while not ESX and not QBCore do
            Wait(50)
            print('Searching for core resource')
            if GetResourceState('es_extended') == 'started' then
                ESX = exports['es_extended']:getSharedObject()
                print(ESX and 'ESX loaded' or 'es_extended not found')
            elseif GetResourceState('qb-core') == 'started' then
                QBCore = exports['qb-core']:GetCoreObject()
                print(QBCore and 'qb-core loaded' or 'qb-core not found')
            end
        end
    end)
end

local function Notify(title, type)
    local duration = Config.NotifyDuration * 1000
    if Config.NotifyType == 'ox' then
        lib.notify({
            title = Config.Translation.notifyTitle,
            description = title,
            type = type,
            duration = duration
        })
    elseif Config.NotifyType == 'okok' then
        exports['okokNotify']:Alert(Config.Translation.notifyTitle, title, duration, type)
    elseif Config.NotifyType == 'esx' then
        ESX.ShowNotification(title, type, duration, "title here")
    elseif Config.NotifyType == 'qb' then
        QBCore.Functions.Notify(title, type, duration)
    else
        lib.notify({
            title = Config.Translation.notifyTitle,
            description = title,
            type = type,
            duration = duration
        })
    end
end

local function isAllowedVehicle(entity)
    return Config.allowedVehicles[GetEntityModel(entity)] == true
end

local function isCop()
    if Config.RequireJob then
        if QBCore then
            for _,v in pairs(Config.Authorizedjobs) do
                if QBCore.Functions.GetPlayerData(source).job.name == v then
                    return true
                end
            end
            return false
        elseif ESX then
            for _,v in pairs(Config.Authorizedjobs) do
                if ESX.PlayerData.job.name == v then
                    return true
                end
            end
            return false
        end
        return false
    else
        return true
    end
end

local function playProgressBar(label, vehicle)
    local door = 5
    local doorAlreadyOpen = false

    if vehicle and DoesEntityExist(vehicle) then
        local doorAngle = GetVehicleDoorAngleRatio(vehicle, door)
        doorAlreadyOpen = doorAngle and doorAngle > 0.1

        if not doorAlreadyOpen then
            SetVehicleDoorOpen(vehicle, door, false, false)
        end
    end

    local success = lib.progressCircle({
        duration = 3500,
        label = label,
        useWhileDead = false,
        allowCuffed = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'mp_car_bomb',
            clip = 'car_bomb_mechanic'
        },
        position = 'bottom'
    })

    if vehicle and DoesEntityExist(vehicle) and not doorAlreadyOpen then
        SetVehicleDoorShut(vehicle, door, false)
    end

    return success
end


local function saveCurrentVest()
    if not originalVest then
        originalVest = {
            item = GetPedDrawableVariation(cache.ped, 9),
            texture = GetPedTextureVariation(cache.ped, 9)
        }
    end
end

local function saveCurrentHelmet()
    local currentProp = GetPedPropIndex(cache.ped, 0)
    if currentProp ~= -1 then
        originalHelmet = {
            prop = currentProp,
            texture = GetPedPropTextureIndex(cache.ped, 0)
        }
    else
        originalHelmet = nil
    end
end

function isLookingAtVehicle(ped, vehicle, maxAngle)
    local pedCoords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local toVehicle = vector3(vehicleCoords.x - pedCoords.x, vehicleCoords.y - pedCoords.y, vehicleCoords.z - pedCoords.z)

    local forward = GetEntityForwardVector(ped)

    toVehicle = toVehicle / #(toVehicle)

    local dot = forward.x * toVehicle.x + forward.y * toVehicle.y + forward.z * toVehicle.z
    local angle = math.deg(math.acos(dot))

    return angle < (maxAngle or 30.0)
end

exports.ox_target:addGlobalVehicle({
    {
        name = 'trunk_take_armor',
        icon = 'fa-solid fa-shield-halved',
        label = Config.Translation.take_armor,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = isAllowedVehicle and isCop,
        onSelect = function(data)
            if BProofTaken then
                return Notify(Config.Translation.bproof_taken, 'error')
            end

            TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

            while not isLookingAtVehicle(cache.ped, data.entity) do
               Wait(50)
            end
            Wait(100)

            if playProgressBar(Config.Translation.putting_armor, data.entity) then
                saveCurrentVest()
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.BProofAddedArmor, 100))
                SetPedComponentVariation(cache.ped, 9, Config.BProofNumber, Config.BProofTexture, 1)
                Notify(Config.Translation.took_armor, 'inform')
                BProofTaken = true
            end
        end
    },
    {
        name = 'trunk_take_vest',
        icon = 'fa-solid fa-vest',
        label = Config.Translation.take_refvest,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = isAllowedVehicle and isCop,
        onSelect = function(data)
            TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

            while not isLookingAtVehicle(cache.ped, data.entity) do
               Wait(50)
            end
            Wait(100)

            if playProgressBar(Config.Translation.putting_vest, data.entity) then
                saveCurrentVest()
                SetPedComponentVariation(cache.ped, 9, Config.RefVestNumber, Config.RefVestTexture, 1)
                Notify(Config.Translation.took_vest, 'inform')
            end
        end
    },
    {
        name = 'trunk_take_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = Config.Translation.take_helmet,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = isAllowedVehicle and isCop,
        onSelect = function(data)
            if hasTakenHelmet then
                return Notify(Config.Translation.helmet_taken, 'error')
            end

            TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

            while not isLookingAtVehicle(cache.ped, data.entity) do
               Wait(50)
            end
            Wait(100)

            if playProgressBar(Config.Translation.putting_helmet, data.entity) then
                saveCurrentHelmet()
                ClearPedProp(cache.ped, 0)
                SetPedPropIndex(cache.ped, 0, Config.HelmetNumber, Config.HelmetTexture, true)
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HelmetAddedArmor, 100))
                Notify(Config.Translation.took_helmet, 'inform')
                hasTakenHelmet = true
            end
        end
    },
    {
        name = 'trunk_remove_armor',
        icon = 'fa-solid fa-vest',
        label = Config.Translation.remove_vest,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = function(entity)
            return isAllowedVehicle(entity) and originalVest ~= nil
        end,
        onSelect = function(data)
            TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

            while not isLookingAtVehicle(cache.ped, data.entity) do
               Wait(50)
            end
            Wait(100)

            if playProgressBar(Config.Translation.removing_vest, data.entity) then
                if BProofTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.BProofAddedArmor, 0))
                end
                SetPedComponentVariation(cache.ped, 9, originalVest.item, originalVest.texture, 1)
                Notify(Config.Translation.removed_vest, 'inform')
                originalVest = nil
                BProofTaken = false
            end
        end
    },
    {
        name = 'trunk_remove_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = Config.Translation.remove_helmet,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = function(entity)
            return isAllowedVehicle(entity) and hasTakenHelmet
        end,
        onSelect = function(data)
            TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

            while not isLookingAtVehicle(cache.ped, data.entity) do
               Wait(50)
            end
            Wait(100)

            if playProgressBar(Config.Translation.removing_helmet, data.entity) then
                SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HelmetAddedArmor, 0))
                ClearPedProp(cache.ped, 0)
                if originalHelmet then
                    SetPedPropIndex(cache.ped, 0, originalHelmet.prop, originalHelmet.texture, true)
                    originalHelmet = nil
                end
                Notify(Config.Translation.removed_helmet, 'inform')
                hasTakenHelmet = false
            end
        end
    }
})