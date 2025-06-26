Config = {}

Config.allowedVehicles = {
    [`police`] = true,
    [`police2`] = true,
    [`fbi`] = true,
    [`fbi2`] = true,
    [`sheriff`] = true,
    [`sheriff2`] = true
}

Config.NotifyType = 'ox' -- ox, okok, esx, qb
Config.NotifyDuration = 5 -- seconds

Config.RequireJob = true -- Does the player need to have a certain job to be able to take gear (Only works on esx, qbx and qbcore)
Config.Authorizedjobs = {'police', 'bcso'} -- Add the job names that you want to be able to use gear

Config.BProofAddedArmor = 50 -- How much bulletproof vest should add armor
Config.HelmetAddedArmor = 25 -- How much helmet should add armor (Armor caps at 100)


Config.BProofNumber = 4 -- Number of the bulletproof vest
Config.BProofTexture = 0 -- Number of the bulletProof vest texture

Config.RefVestNumber = 21 -- Number of the reflective vest
Config.RefVestTexture = 0 -- Number of the reflective vest texture

Config.HelmetNumber = 59 -- number of the helmet
Config.HelmetTexture = 0 -- number of the helmet texture


Config.Translation = {
    take_armor = "Grab bulletproof vest",
    putting_armor = "Equipping bulletproof vest...",
    took_armor = "You've equipped a bulletproof vest.",
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