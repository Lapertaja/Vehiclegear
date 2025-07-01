## Vehiclegear
This script allows players to interact with police vehicle trunks to equip and remove tactical gear using ox_target and ox_inventory. Designed for immersive roleplay and realistic loadout management.

---

## Features

- **ox_target integration**
  - Context menu opens when aiming at vehicle trunk

- **Equip & remove gear directly from the trunk**
  - Bulletproof vest (adds armor)
  - Reflective vest
  - Helmet (adds armor)
  - Each with animations and progress circles
  - Restrictions for taking gear so players don't spam full armor
  - Removing gear is only possible when gear has been equipped from the trunk
  - Choose which gear you want enabled

- **Customizable access**
  - Only vehicles listed in `allowedVehicles` can be used
  - The script has the possibility to job lock the gear
    - Only authorized jobs listed in `Authorizedjobs` can utilize gear
    - Also the possibility to disable so that everyone can take gear
  - Possibility to make it so that the vehicle needs to be unlocked to be able to take gear

- **Gear memory system**
  - Restores original gear when removing the new one

- **Immersive experience**
  - Trunk opens before equipping
  - Equipping starts only after the trunk is open
  - Recognizes if trunk was already open (does not close it)
  - Player is turned towards the trunk before gear is equipped
  - Progress animations and UI feedback

---

## Dependencies

- [ox_target](https://overextended.dev/ox_target)
- [ox_inventory](https://overextended.dev/ox_inventory)
- [ox_lib](https://overextended.dev/ox_lib)

---

## To-do
- Add item restriction possibility so that the gear has to be in the trunk to equip
- Add vehicle restriction possibility
  - Only certain vehicles can give certain equipment (Bearcat can give heavier gear, bike only helmet etc.)