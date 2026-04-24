local originalVest = nil
local originalHelmet = nil
local hasTakenHelmet = false
local BProofTaken = false
local HVestTaken = false
local RefVestTaken = false

local function Notify(desc, type)
    local duration = Config.NotifyDuration * 1000
    Config.Notify(Config.Translation.notifyTitle, desc, type, duration)
end

---@return boolean isAllowedVehicle
local function isAllowedVehicle(entity)
    for _, v in pairs(Config.allowedVehicles) do
        return v.name == GetEntityModel(entity)
    end
    return false
end

---@return boolean canGetFromVehicle
local function vehicleRestriction(gear)
    if not Config.VehicleRestricted then return true end

    for _, v in ipairs(Config.allowedVehicles) do
        for _, i in pairs(v.gear) do
            return i == gear
        end
    end
    return false
end

---@return boolean progressbarPlayed
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

    if success and Config.Sound.Enable then
        PlaySoundFrontend(-1, Config.Sound.Name, Config.Sound.Set, true)
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

---@return boolean isLookingAtVehicle
local function isLookingAtVehicle(ped, vehicle, maxAngle)
    local pedCoords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local toVehicle = vector3(vehicleCoords.x - pedCoords.x, vehicleCoords.y - pedCoords.y, vehicleCoords.z - pedCoords
        .z)

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
        bones = { 'boot', 'trunk' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            local allowed = isAllowedVehicle(entity) and Config.BProofNumber ~= nil and not BProofTaken and
                not HVestTaken and not RefVestTaken
            if Config.RequireUnlocked then
                allowed = allowed and GetVehicleDoorLockStatus(entity) == 1
            end
            if Config.VehicleRestricted then
                allowed = allowed and vehicleRestriction('bproof')
            end
            return allowed
        end,
        onSelect = function(data)
            if BProofTaken then
                return Notify(Config.Translation.bproof_taken, 'error')
            end
            local itemIsInTrunk = true

            local plate = string.gsub(GetVehicleNumberPlateText(data.entity), '^%s*(.-)%s*$', '%1')
            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.BProofItem)
            end

            if itemIsInTrunk then
                TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

                while not isLookingAtVehicle(cache.ped, data.entity) do
                    Wait(50)
                end
                Wait(100)

                if playProgressBar(Config.Translation.putting_armor, data.entity) then
                    saveCurrentVest()
                    SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.BProofAddedArmor, 100))
                    SetPedComponentVariation(cache.ped, 9, Config.BProofNumber, Config.BProofTexture, 1)

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.BProofItem, plate)
                    end

                    Notify(Config.Translation.took_armor, 'inform')
                    BProofTaken = true
                end
            else
                Notify(Config.Translation.not_in_trunk, 'error')
            end
        end
    },
    {
        name = 'trunk_take_heavy_armor',
        icon = 'fa-solid fa-shield-halved',
        label = Config.Translation.take_heavy,
        bones = { 'boot', 'trunk' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            local allowed = isAllowedVehicle(entity) and Config.HeavyVestNumber ~= nil and not BProofTaken and
                not HVestTaken and not RefVestTaken
            if Config.RequireUnlocked then
                allowed = allowed and GetVehicleDoorLockStatus(entity) == 1
            end
            if Config.VehicleRestricted then
                allowed = allowed and vehicleRestriction('heavy')
            end
            return allowed
        end,
        onSelect = function(data)
            if BProofTaken then
                return Notify(Config.Translation.bproof_taken, 'error')
            end
            local itemIsInTrunk = true

            local plate = string.gsub(GetVehicleNumberPlateText(data.entity), '^%s*(.-)%s*$', '%1')
            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.HeavyVestItem)
            end

            if itemIsInTrunk then
                TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

                while not isLookingAtVehicle(cache.ped, data.entity) do
                    Wait(50)
                end
                Wait(100)

                if playProgressBar(Config.Translation.putting_heavy, data.entity) then
                    saveCurrentVest()
                    SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HVestAddedArmor, 100))
                    SetPedComponentVariation(cache.ped, 9, Config.HeavyVestNumber, Config.HeavyVestTexture, 1)

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.HeavyVestItem, plate)
                    end

                    Notify(Config.Translation.took_heavy, 'inform')
                    HVestTaken = true
                end
            else
                Notify(Config.Translation.not_in_trunk, 'error')
            end
        end
    },
    {
        name = 'trunk_take_vest',
        icon = 'fa-solid fa-vest',
        label = Config.Translation.take_refvest,
        bones = { 'boot', 'trunk' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            local allowed = isAllowedVehicle(entity) and Config.RefVestNumber ~= nil and not BProofTaken and
                not HVestTaken and not RefVestTaken
            if Config.RequireUnlocked then
                allowed = allowed and GetVehicleDoorLockStatus(entity) == 1
            end
            if Config.VehicleRestricted then
                allowed = allowed and vehicleRestriction('refvest')
            end
            return allowed
        end,
        onSelect = function(data)
            if RefVestTaken then
                return Notify(Config.Translation.bproof_taken, 'error')
            end
            local itemIsInTrunk = true

            local plate = string.gsub(GetVehicleNumberPlateText(data.entity), '^%s*(.-)%s*$', '%1')
            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.RefVestItem)
            end

            if itemIsInTrunk then
                TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

                while not isLookingAtVehicle(cache.ped, data.entity) do
                    Wait(50)
                end
                Wait(100)

                if playProgressBar(Config.Translation.putting_vest, data.entity) then
                    saveCurrentVest()
                    SetPedComponentVariation(cache.ped, 9, Config.RefVestNumber, Config.RefVestTexture, 1)

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.RefVestItem, plate)
                    end

                    Notify(Config.Translation.took_vest, 'inform')
                    RefVestTaken = true
                end
            else
                Notify(Config.Translation.not_in_trunk, 'error')
            end
        end
    },
    {
        name = 'trunk_take_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = Config.Translation.take_helmet,
        bones = { 'boot', 'trunk' },
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            local allowed = isAllowedVehicle(entity) and Config.HelmetNumber ~= nil and not hasTakenHelmet
            if Config.RequireUnlocked then
                allowed = allowed and GetVehicleDoorLockStatus(entity) == 1
            end
            if Config.VehicleRestricted then
                allowed = allowed and vehicleRestriction('helmet')
            end
            return allowed
        end,
        onSelect = function(data)
            if hasTakenHelmet then
                return Notify(Config.Translation.helmet_taken, 'error')
            end
            local itemIsInTrunk = true

            local plate = string.gsub(GetVehicleNumberPlateText(data.entity), '^%s*(.-)%s*$', '%1')
            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.HelmetItem)
            end

            if itemIsInTrunk then
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

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.HelmetItem, plate)
                    end

                    Notify(Config.Translation.took_helmet, 'inform')
                    hasTakenHelmet = true
                end
            else
                Notify(Config.Translation.not_in_trunk, 'error')
            end
        end
    },
    {
        name = 'trunk_remove_armor',
        icon = 'fa-solid fa-vest',
        label = Config.Translation.remove_vest,
        bones = { 'boot', 'trunk' },
        distance = 1.0,
        canInteract = function(entity)
            return isAllowedVehicle(entity) and originalVest ~= nil
        end,
        onSelect = function(data)
            local plate = string.gsub(GetVehicleNumberPlateText(data.entity), '^%s*(.-)%s*$', '%1')
            TaskTurnPedToFaceEntity(cache.ped, data.entity, 1000)

            while not isLookingAtVehicle(cache.ped, data.entity) do
                Wait(50)
            end
            Wait(100)

            if playProgressBar(Config.Translation.removing_vest, data.entity) then
                if HVestTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HVestAddedArmor, 0))

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:addItem', Config.HeavyVestItem, plate)
                    end
                elseif BProofTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.BProofAddedArmor, 0))

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:addItem', Config.BProofItem, plate)
                    end
                elseif RefVestTaken then
                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:addItem', Config.RefVestItem, plate)
                    end
                end

                if originalVest then
                    SetPedComponentVariation(cache.ped, 9, originalVest.item, originalVest.texture, 1)
                end

                Notify(Config.Translation.removed_vest, 'inform')
                originalVest = nil
                BProofTaken = false
                HVestTaken = false
                RefVestTaken = false
            end
        end
    },
    {
        name = 'trunk_remove_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = Config.Translation.remove_helmet,
        bones = { 'boot', 'trunk' },
        distance = 1.0,
        canInteract = function(entity)
            return isAllowedVehicle(entity) and hasTakenHelmet
        end,
        onSelect = function(data)
            local plate = string.gsub(GetVehicleNumberPlateText(data.entity), '^%s*(.-)%s*$', '%1')
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

                if Config.RequireItems then
                    TriggerServerEvent('vehiclegear:addItem', Config.HelmetItem, plate)
                end

                Notify(Config.Translation.removed_helmet, 'inform')
                hasTakenHelmet = false
            end
        end
    }
})
