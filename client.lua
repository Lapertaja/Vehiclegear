lib.locale()

local originalVest = nil
local originalHelmet = nil
local hasTakenHelmet = false
local BProofTaken = false
local HVestTaken = false
local RefVestTaken = false

local allowedHashes = {}

CreateThread(function()
    for _, v in ipairs(Config.allowedVehicles) do
        allowedHashes[joaat(v.name)] = v
    end
end)

-- Handlebars is temporary so that all bikes work
local bones = { 'boot', 'trunk', 'handlebars' }

local function Notify(desc, type)
    local duration = Config.NotifyDuration * 1000
    Config.Notify(locale('notifyTitle'), desc, type, duration)
end

---@return string plate
local function getPlate(entity)
    if not entity then return '' end
    local props = lib.getVehicleProperties(entity)
    local plate = props and props.plate or GetVehicleNumberPlateText(entity)
    return plate and string.trim(plate) or ''
end

---@return boolean canTakeGear
local function canTakeGear(entity, gear)
    local model = GetEntityModel(entity)
    local v = allowedHashes[model]
    if not v then return false end

    if Config.VehicleRestricted and v.gear then
        local hasGear = false
        for i = 1, #v.gear do
            if v.gear[i] == gear then
                hasGear = true
                break
            end
        end
        if not hasGear then return false end
    end

    if Config.RequireUnlocked and GetVehicleDoorLockStatus(entity) ~= 1 then
        return false
    end

    return true
end

---@return boolean progressbarPlayed
local function playProgressBar(label, vehicle)
    local door = 5
    local doorAlreadyOpen = false
    local hasDoor = false

    if vehicle then
        local doorAngle = GetVehicleDoorAngleRatio(vehicle, door)
        if doorAngle then
            hasDoor = true
            doorAlreadyOpen = doorAngle > 0.1
            if not doorAlreadyOpen then
                SetVehicleDoorOpen(vehicle, door, false, false)
            end
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

    if hasDoor and vehicle and DoesEntityExist(vehicle) and not doorAlreadyOpen then
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
    local toVehicle = vector3(vehicleCoords.x - pedCoords.x, vehicleCoords.y - pedCoords.y, vehicleCoords.z - pedCoords.z)

    local forward = GetEntityForwardVector(ped)
    toVehicle = toVehicle / #(toVehicle)

    local dot = forward.x * toVehicle.x + forward.y * toVehicle.y + forward.z * toVehicle.z
    local angle = math.deg(math.acos(dot))

    return angle < (maxAngle or 30.0)
end

local function turnPedToVehicle(ped, vehicle)
    TaskTurnPedToFaceEntity(ped, vehicle, 1000)
    local timeout = 20
    while not isLookingAtVehicle(ped, vehicle) and timeout > 0 do
        timeout = timeout - 1
        Wait(50)
    end
    Wait(100)
end

exports.ox_target:addGlobalVehicle({
    {
        name = 'trunk_take_armor',
        icon = 'fa-solid fa-shield-halved',
        label = locale('take_armor'),
        bones = bones,
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            if Config.BProofNumber == nil or BProofTaken or HVestTaken or RefVestTaken then return false end
            return canTakeGear(entity, 'bproof')
        end,
        onSelect = function(data)
            if BProofTaken then
                return Notify(locale('bproof_taken'), 'error')
            end
            local itemIsInTrunk = true
            local plate = getPlate(data.entity)

            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.AuthorizedItems.BProofItem)
            end

            if itemIsInTrunk then
                turnPedToVehicle(cache.ped, data.entity)

                if playProgressBar(locale('putting_armor'), data.entity) then
                    saveCurrentVest()
                    SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.BProofAddedArmor, 100))
                    SetPedComponentVariation(cache.ped, 9, Config.BProofNumber, Config.BProofTexture, 1)

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.AuthorizedItems.BProofItem, plate, VehToNet(data.entity))
                    end

                    Notify(locale('took_armor'), 'inform')
                    BProofTaken = true
                end
            else
                Notify(locale('not_in_trunk'), 'error')
            end
        end
    },
    {
        name = 'trunk_take_heavy_armor',
        icon = 'fa-solid fa-shield-halved',
        label = locale('take_heavy'),
        bones = bones,
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            if Config.HeavyVestNumber == nil or BProofTaken or HVestTaken or RefVestTaken then return false end
            return canTakeGear(entity, 'heavy')
        end,
        onSelect = function(data)
            if BProofTaken then
                return Notify(locale('bproof_taken'), 'error')
            end
            local itemIsInTrunk = true
            local plate = getPlate(data.entity)

            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.AuthorizedItems.HeavyVestItem)
            end

            if itemIsInTrunk then
                turnPedToVehicle(cache.ped, data.entity)

                if playProgressBar(locale('putting_heavy'), data.entity) then
                    saveCurrentVest()
                    SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HVestAddedArmor, 100))
                    SetPedComponentVariation(cache.ped, 9, Config.HeavyVestNumber, Config.HeavyVestTexture, 1)

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.AuthorizedItems.HeavyVestItem, plate, VehToNet(data.entity))
                    end

                    Notify(locale('took_heavy'), 'inform')
                    HVestTaken = true
                end
            else
                Notify(locale('not_in_trunk'), 'error')
            end
        end
    },
    {
        name = 'trunk_take_vest',
        icon = 'fa-solid fa-vest',
        label = locale('take_refvest'),
        bones = bones,
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            if Config.RefVestNumber == nil or BProofTaken or HVestTaken or RefVestTaken then return false end
            return canTakeGear(entity, 'refvest')
        end,
        onSelect = function(data)
            if RefVestTaken then
                return Notify(locale('bproof_taken'), 'error')
            end
            local itemIsInTrunk = true
            local plate = getPlate(data.entity)

            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.AuthorizedItems.RefVestItem)
            end

            if itemIsInTrunk then
                turnPedToVehicle(cache.ped, data.entity)

                if playProgressBar(locale('putting_vest'), data.entity) then
                    saveCurrentVest()
                    SetPedComponentVariation(cache.ped, 9, Config.RefVestNumber, Config.RefVestTexture, 1)

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.AuthorizedItems.RefVestItem, plate, VehToNet(data.entity))
                    end

                    Notify(locale('took_vest'), 'inform')
                    RefVestTaken = true
                end
            else
                Notify(locale('not_in_trunk'), 'error')
            end
        end
    },
    {
        name = 'trunk_take_helmet',
        icon = 'fa-solid fa-hard-hat',
        label = locale('take_helmet'),
        bones = bones,
        distance = 1.0,
        groups = Config.Authorizedjobs,
        canInteract = function(entity)
            if Config.HelmetNumber == nil or hasTakenHelmet then return false end
            return canTakeGear(entity, 'helmet')
        end,
        onSelect = function(data)
            if hasTakenHelmet then
                return Notify(locale('helmet_taken'), 'error')
            end
            local itemIsInTrunk = true
            local plate = getPlate(data.entity)

            if Config.RequireItems then
                itemIsInTrunk = lib.callback.await('vehiclegear:isItemInTrunk', false, plate, Config.AuthorizedItems.HelmetItem)
            end

            if itemIsInTrunk then
                turnPedToVehicle(cache.ped, data.entity)

                if playProgressBar(locale('putting_helmet'), data.entity) then
                    saveCurrentHelmet()
                    ClearPedProp(cache.ped, 0)
                    SetPedPropIndex(cache.ped, 0, Config.HelmetNumber, Config.HelmetTexture, true)
                    SetPedArmour(cache.ped, math.min(GetPedArmour(cache.ped) + Config.HelmetAddedArmor, 100))

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:removeItem', Config.AuthorizedItems.HelmetItem, plate, VehToNet(data.entity))
                    end

                    Notify(locale('took_helmet'), 'inform')
                    hasTakenHelmet = true
                end
            else
                Notify(locale('not_in_trunk'), 'error')
            end
        end
    },
    {
        name = 'trunk_remove_armor',
        icon = 'fa-solid fa-vest',
        label = locale('remove_vest'),
        bones = bones,
        distance = 1.0,
        canInteract = function(entity)
            if not originalVest then return false end
            return allowedHashes[GetEntityModel(entity)] ~= nil
        end,
        onSelect = function(data)
            local plate = getPlate(data.entity)
            turnPedToVehicle(cache.ped, data.entity)

            if playProgressBar(locale('removing_vest'), data.entity) then
                if HVestTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HVestAddedArmor, 0))

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:addItem', Config.AuthorizedItems.HeavyVestItem, plate, VehToNet(data.entity))
                    end
                elseif BProofTaken then
                    SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.BProofAddedArmor, 0))

                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:addItem', Config.AuthorizedItems.BProofItem, plate, VehToNet(data.entity))
                    end
                elseif RefVestTaken then
                    if Config.RequireItems then
                        TriggerServerEvent('vehiclegear:addItem', Config.AuthorizedItems.RefVestItem, plate, VehToNet(data.entity))
                    end
                end

                if originalVest then
                    SetPedComponentVariation(cache.ped, 9, originalVest.item, originalVest.texture, 1)
                end

                Notify(locale('removed_vest'), 'inform')
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
        label = locale('remove_helmet'),
        bones = bones,
        distance = 1.0,
        canInteract = function(entity)
            if not hasTakenHelmet then return false end
            return allowedHashes[GetEntityModel(entity)] ~= nil
        end,
        onSelect = function(data)
            local plate = getPlate(data.entity)
            turnPedToVehicle(cache.ped, data.entity)

            if playProgressBar(locale('removing_helmet'), data.entity) then
                SetPedArmour(cache.ped, math.max(GetPedArmour(cache.ped) - Config.HelmetAddedArmor, 0))
                ClearPedProp(cache.ped, 0)

                if originalHelmet then
                    SetPedPropIndex(cache.ped, 0, originalHelmet.prop, originalHelmet.texture, true)
                    originalHelmet = nil
                end

                if Config.RequireItems then
                    TriggerServerEvent('vehiclegear:addItem', Config.AuthorizedItems.HelmetItem, plate, VehToNet(data.entity))
                end

                Notify(locale('removed_helmet'), 'inform')
                hasTakenHelmet = false
            end
        end
    }
})


