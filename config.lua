Config = {}

Config.allowedVehicles = {
    [`police`] = true,
    [`police2`] = true,
    [`fbi`] = true,
    [`fbi2`] = true,
    [`sheriff`] = true,
    [`sheriff2`] = true
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

Config.Authorizedjobs = { 'police', 'bcso' } -- Add the job names that you want to be able to use gear (nil or empty table to disable)

Config.RequireUnlocked = false               -- Does the vehicle need to be unlocked to equip gear?
Config.RequireItems = true                   -- Do the items need to be in the trunk to be equipped

Config.BProofAddedArmor = 50                 -- How much bulletproof vest should add armor
Config.HVestAddedArmor = 75                  -- How much heavy armor should add armor
Config.HelmetAddedArmor = 25                 -- How much helmet should add armor (Armor caps at 100)

Config.BProofNumber = 4                      -- Number of the bulletproof vest (set to nil if you want to disable)
Config.BProofTexture = 0                     -- Number of the bulletproof vest texture
Config.BProofItem = 'armour'                 -- Name of the bulletproof vest item / false

Config.HeavyVestNumber = 20                  -- Number of the heavy vest (set to nil if you want to disable)
Config.HeavyVestTexture = 0                  -- Number of the heavy vest texture
Config.HeavyVestItem = false                 -- Name of the heavy vest item / false

Config.RefVestNumber = 21                    -- Number of the reflective vest (set to nil if you want to disable)
Config.RefVestTexture = 0                    -- Number of the reflective vest texture
Config.RefVestItem = false                   -- Name of the reflective vest item / false

Config.HelmetNumber = 59                     -- number of the helmet (set to nil if you want to disable)
Config.HelmetTexture = 0                     -- number of the helmet texture
Config.HelmetItem = false                    -- Name of the helmet item / false


Config.Translation = {
    take_armor = "Grab bulletproof vest",
    putting_armor = "Equipping bulletproof vest...",
    took_armor = "You've equipped a bulletproof vest.",

    take_heavy = "Grab heavy vest",
    putting_heavy = "Equipping heavy vest...",
    took_heavy = "You've equipped a heavy vest",
    bproof_taken = "You already have a bulletproof vest.",

    take_refvest = "Grab reflective vest",
    putting_vest = "Putting on reflective vest...",
    took_vest = "You've put on a reflective vest.",

    take_helmet = "Grab bulletproof helmet",
    putting_helmet = "Equipping bulletproof helmet...",
    took_helmet = "You've equipped a bulletproof helmet.",
    helmet_taken = "You already have a bulletproof helmet.",

    remove_vest = "Remove vest",
    removing_vest = "Taking off vest...",
    removed_vest = "You removed your vest.",

    remove_helmet = "Remove helmet",
    removing_helmet = "Taking off helmet...",
    removed_helmet = "You removed your helmet.",

    not_in_trunk = 'Item is not in the trunk',

    notifyTitle = "Gear system"
}
