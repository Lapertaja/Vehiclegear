## Vehiclegear
This script allows players to interact with police vehicle trunks to equip and remove tactical gear using ox_target and ox_inventory. Designed for immersive roleplay and realistic loadout management.

---

## ✨ Features

- 🎯 **ox_target integration**
  - Context menu opens when aiming at vehicle trunk (door 5)

- 🛡️ **Equip & remove gear directly from the trunk**
  - Bulletproof vest (adds armor)
  - Reflective vest
  - Helmet (adds armor)
  - Each with animations and progress bars

- 🎒 **ox_inventory integration**
  - Items must be present in the trunk
  - Items are removed when equipped and returned when unequipped

- 🔐 **Customizable vehicle access**
  - Only vehicles listed in `allowedVehicles` can be used

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
- [lib](https://overextended.dev/lib)