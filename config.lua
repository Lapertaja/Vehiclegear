Config = {}

Config.allowedVehicles = {
    {
        name = 'police',
        gear = { 'bproof', 'refvest', 'helmet' }
    },
    {
        name = 'policeb',
        gear = { 'refvest', 'helmet' }
    },
    {
        name = 'bearcat',
        gear = { 'bproof', 'heavy', 'refvest', 'helmet' }
    }
}

Config.NotifyDuration = 5 -- seconds

Config.Notify = function(title, desc, type, duration)
    lib.notify({
        title = title,
        description = desc,
        type = type,
        duration = duration
    })
end

Config.Sound = {
    Enable = false,
    Name = "CHALLENGE_UNLOCKED",
    Set = "HUD_AWARDS"
}

Config.Authorizedjobs = { 'police', 'bcso' } -- Add the job names that you want to be able to use gear (nil or empty table to disable)

Config.AuthorizedItems = {
    BProofItem = 'armour',                  -- Name of the bulletproof vest item / false
    HeavyVestItem = false,                  -- Name of the heavy vest item / false
    RefVestItem = false,                    -- Name of the reflective vest item / false
    HelmetItem = false                      -- Name of the helmet item / false
}

Config.RequireUnlocked = false               -- Does the vehicle need to be unlocked to equip gear?
Config.RequireItems = true                   -- Do the items need to be in the trunk to be equipped
Config.VehicleRestricted = true              -- Restrict gear to certain vehicles

Config.BProofAddedArmor = 50                 -- How much bulletproof vest should add armor
Config.HVestAddedArmor = 75                  -- How much heavy armor should add armor
Config.HelmetAddedArmor = 25                 -- How much helmet should add armor (Armor caps at 100)

Config.BProofNumber = 4                      -- Number of the bulletproof vest (set to nil if you want to disable)
Config.BProofTexture = 0                     -- Number of the bulletproof vest texture

Config.HeavyVestNumber = 20                  -- Number of the heavy vest (set to nil if you want to disable)
Config.HeavyVestTexture = 0                  -- Number of the heavy vest texture

Config.RefVestNumber = 21                    -- Number of the reflective vest (set to nil if you want to disable)
Config.RefVestTexture = 0                    -- Number of the reflective vest texture

Config.HelmetNumber = 59                     -- number of the helmet (set to nil if you want to disable)
Config.HelmetTexture = 0                     -- number of the helmet texture