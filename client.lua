local originalVest = nil
local originalHelmet = nil
local hasTakenHelmet = false
local BProofTaken = false
local HVestTaken = false
local RefVestTaken = false

local function isAllowedVehicle(entity)
    return Config.allowedVehicles[GetEntityModel(entity)] == true
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

-- Shared helper: checks vehicle type + unlock state
local function canInteractTrunk(entity, extraCondition)
    if not isAllowedVehicle(entity) then return false end
    if Config.RequireUnlocked and GetVehicleDoorLockStatus(entity) ~= 1 then return false end
    return extraCondition == nil or extraCondition
end

-- Shared helper: face vehicle, wait for turn, run progress bar, then callback
local function doGearAction(data, label, callback)
    TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)
    Wait(1000)
    if playProgressBar(label, data.entity) then
        callback()
    end
end

exports.ox_target:addGlobalVehicle({
    {
        name = 'trunk_take_armor',
        icon = 'fa-solid fa-shield-halved',
        label = Config.Translation.take_armor,
        bones = { 'boot' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            return canInteractTrunk(entity,
                Config.BProofNumber ~= nil and not BProofTaken and not HVestTaken and not RefVestTaken)
        end,
        onSelect = function(data)
            if BProofTaken then
                return Config.Notify(Config.Translation.bproof_taken, 'error')
            end
            doGearAction(data, Config.Translation.putting_armor, function()
                saveCurrentVest()
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.BProofAddedArmor, 100))
                SetPedComponentVariation(cache.ped, 9, Config.BProofNumber, Config.BProofTexture, 1)
                Config.Notify(Config.Translation.took_armor, 'inform')
                BProofTaken = true
            end)
        end
    },
    {
        name = 'trunk_take_heavy_armor',
        icon = 'fa-solid fa-shield-halved',
        label = Config.Translation.take_heavy,
        bones = { 'boot' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            return canInteractTrunk(entity,
                Config.HeavyVestNumber ~= nil and not BProofTaken and not HVestTaken and not RefVestTaken)
        end,
        onSelect = function(data)
            if BProofTaken then
                return Config.Notify(Config.Translation.bproof_taken, 'error')
            end
            doGearAction(data, Config.Translation.putting_heavy, function()
                saveCurrentVest()
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HVestAddedArmor, 100))
                SetPedComponentVariation(cache.ped, 9, Config.HeavyVestNumber, Config.HeavyVestTexture, 1)
                Config.Notify(Config.Translation.took_heavy, 'inform')
                HVestTaken = true
            end)
        end
    },
    {
        name = 'trunk_take_vest',
        icon = 'fa-solid fa-vest',
        label = Config.Translation.take_refvest,
        bones = { 'boot' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            return canInteractTrunk(entity,
                Config.RefVestNumber ~= nil and not BProofTaken and not HVestTaken and not RefVestTaken)
        end,
        onSelect = function(data)
            doGearAction(data, Config.Translation.putting_vest, function()
                saveCurrentVest()
                SetPedComponentVariation(cache.ped, 9, Config.RefVestNumber, Config.RefVestTexture, 1)
                Config.Notify(Config.Translation.took_vest, 'inform')
                RefVestTaken = true
            end)
        end
    },
    {
        name = 'trunk_take_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = Config.Translation.take_helmet,
        bones = { 'boot' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            return canInteractTrunk(entity, Config.HelmetNumber ~= nil and not hasTakenHelmet)
        end,
        onSelect = function(data)
            if hasTakenHelmet then
                return Config.Notify(Config.Translation.helmet_taken, 'error')
            end
            doGearAction(data, Config.Translation.putting_helmet, function()
                saveCurrentHelmet()
                ClearPedProp(cache.ped, 0)
                SetPedPropIndex(cache.ped, 0, Config.HelmetNumber, Config.HelmetTexture, true)
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HelmetAddedArmor, 100))
                Config.Notify(Config.Translation.took_helmet, 'inform')
                hasTakenHelmet = true
            end)
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
            doGearAction(data, Config.Translation.removing_vest, function()
                if HVestTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HVestAddedArmor, 0))
                elseif BProofTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.BProofAddedArmor, 0))
                end
                SetPedComponentVariation(cache.ped, 9, originalVest.item, originalVest.texture, 1)
                Config.Notify(Config.Translation.removed_vest, 'inform')
                originalVest = nil
                BProofTaken = false
                HVestTaken = false
                RefVestTaken = false
            end)
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
            doGearAction(data, Config.Translation.removing_helmet, function()
                SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HelmetAddedArmor, 0))
                ClearPedProp(cache.ped, 0)
                if originalHelmet then
                    SetPedPropIndex(cache.ped, 0, originalHelmet.prop, originalHelmet.texture, true)
                    originalHelmet = nil
                end
                Config.Notify(Config.Translation.removed_helmet, 'inform')
                hasTakenHelmet = false
            end)
        end
    }
})
