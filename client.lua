local originalVest = nil
local originalHelmet = nil
local hasTakenHelmet = false
local BProofTaken = false

local allowedVehicles = {
    [`police`] = true,
    [`police2`] = true,
    [`fbi`] = true,
    [`fbi2`] = true,
    [`sheriff`] = true,
    [`sheriff2`] = true
}

local function isAllowedVehicle(entity)
    return allowedVehicles[GetEntityModel(entity)] == true
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

exports.ox_target:addGlobalVehicle({
    {
        name = 'trunk_take_armor',
        icon = 'fa-solid fa-shield-halved',
        label = Config.Translation.take_armor,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = isAllowedVehicle,
        onSelect = function(data)
            if BProofTaken then
                return lib.notify({ title = Config.Translation.bproof_taken, type = 'error' })
            end

            if playProgressBar(Config.Translation.putting_armor, data.entity) then
                saveCurrentVest()
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.BProofAddedArmor, 100))
                SetPedComponentVariation(cache.ped, 9, Config.BProofNumber, Config.BProofTexture, 1)
                lib.notify({ title = Config.Translation.took_armor, type = 'inform' })
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
        canInteract = isAllowedVehicle,
        onSelect = function(data)
            if playProgressBar(Config.Translation.putting_vest, data.entity) then
                saveCurrentVest()
                SetPedComponentVariation(cache.ped, 9, Config.RefVestNumber, Config.RefVestTexture, 1)
                lib.notify({ title = Config.Translation.took_vest, type = 'inform' })
            end
        end
    },
    {
        name = 'trunk_take_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = Config.Translation.take_helmet,
        bones = { 'boot' },
        distance = 1.0,
        canInteract = isAllowedVehicle,
        onSelect = function(data)
            if hasTakenHelmet then
                return lib.notify({ title = Config.Translation.helmet_taken, type = 'error' })
            end

            if playProgressBar(Config.Translation.putting_helmet, data.entity) then
                saveCurrentHelmet()
                ClearPedProp(cache.ped, 0)
                SetPedPropIndex(cache.ped, 0, Config.HelmetNumber, Config.HelmetTexture, true)
                SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HelmetAddedArmor, 100))
                lib.notify({ title = Config.Translation.took_helmet, type = 'inform' })
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
            if playProgressBar(Config.Translation.removing_vest, data.entity) then
                if BProofTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.BProofAddedArmor, 0))
                end
                SetPedComponentVariation(cache.ped, 9, originalVest.item, originalVest.texture, 1)
                lib.notify({ title = Config.Translation.removed_vest, type = 'inform' })
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
            if playProgressBar(Config.Translation.removing_helmet, data.entity) then
                SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HelmetAddedArmor, 0))
                ClearPedProp(cache.ped, 0)
                if originalHelmet then
                    SetPedPropIndex(cache.ped, 0, originalHelmet.prop, originalHelmet.texture, true)
                    originalHelmet = nil
                end
                lib.notify({ title = Config.Translation.removed_helmet, type = 'inform' })
                hasTakenHelmet = false
            end
        end
    }
})