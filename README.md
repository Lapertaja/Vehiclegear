## Vehiclegear
This script allows players to interact with police vehicle trunks to equip and remove tactical gear using ox_target and ox_inventory. Designed for immersive roleplay and realistic loadout management.

---

## ✨ Features

- 🎯 **ox_target integration**
  - Context menu opens when aiming at vehicle trunk

- 🛡️ **Equip & remove gear directly from the trunk**
  - Bulletproof vest (adds armor)
  - Reflective vest
  - Helmet (adds armor)
  - Each with animations and progress circles
  - Restrictions for taking gear so players don't spam full armor
  - Removing gear is only possible when gear has been equipped from the trunk

- 🔐 **Customizable vehicle access**
  - Only vehicles listed in `allowedVehicles` can be used (client.lua)

- 🧠 **Gear memory system**
  - Restores original gear when removing the new one

- 🎥 **Immersive experience**
  - Trunk opens before equipping
  - Equipping starts only after the trunk is open
  - Recognizes if trunk was already open (does not close it)
  - Progress animations and UI feedback

---

## 📦 Dependencies

- [ox_target](https://overextended.dev/ox_target)
- [ox_inventory](https://overextended.dev/ox_inventory)
- [ox_lib](https://overextended.dev/ox_lib)

---

## To-do
- Add support for other notification scripts
- Add item restriction possibility so that the gear has to be in the trunk to equip
- Add more locales
