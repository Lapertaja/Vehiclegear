Config = {}

Config.allowedVehicles = {
    [`police`] = true,
    [`police2`] = true,
    [`fbi`] = true,
    [`fbi2`] = true,
    [`sheriff`] = true,
    [`sheriff2`] = true
}

Config.NotifyType = 'ox' -- ox, okok, esx, qb, custom (set in client.lua)
Config.NotifyDuration = 5 -- seconds

Config.RequireJob = true -- Does the player need to have a certain job to be able to take gear (Only works on esx, qbx and qbcore)
Config.Authorizedjobs = {'police', 'bcso'} -- Add the job names that you want to be able to use gear

Config.RequireUnlocked = false -- Does the vehicle need to be unlocked to equip gear?

Config.BProofAddedArmor = 50 -- How much bulletproof vest should add armor
Config.HVestAddedArmor = 75 -- How much heavy armor should add armor
Config.HelmetAddedArmor = 25 -- How much helmet should add armor (Armor caps at 100)

Config.BProofNumber = 4 -- Number of the bulletproof vest   (set to nil if you want to disable)
Config.BProofTexture = 0 -- Number of the bulletproof vest texture

Config.HeavyVestNumber = 20 -- Number of the heavy vest    (set to nil if you want to disable)
Config.HeavyVestTexture = 0 -- Number of the heavy vest texture

Config.RefVestNumber = 21 -- Number of the reflective vest  (set to nil if you want to disable)
Config.RefVestTexture = 0 -- Number of the reflective vest texture

Config.HelmetNumber = 59 -- number of the helmet            (set to nil if you want to disable)
Config.HelmetTexture = 0 -- number of the helmet texture


Config.Translation = {
    take_armor = "Grab bulletproof vest",
    putting_armor = "Equipping bulletproof vest...",
    took_armor = "You've equipped a bulletproof vest.",

    take_heavy = "Grab heavy vest",
    putting_heavy = "Equipping heavy vest...",
    took_heavy = "You've equipped a heavt vest",
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

    notifyTitle = "Gear system"
}