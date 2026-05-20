# SANCHEI Nullius Compat Fixes

Compatibility bundle for the SANCHEI Nullius Factorio mod set.

This mod combines the local fixes that were previously split across several small patch mods.

## Fixes Included

- Entangled Belts:
  - Creates missing recipes for entangled Nullius underground belts.
  - Adds the entangled belt recipes to `nullius-logistics-1` through `nullius-logistics-4`.
  - Removes invalid technology unlock effects when the referenced recipe does not exist.
- Deadlock Beltboxes & Loaders:
  - Removes invalid `next_upgrade` links from loaders when the target has no visible builder item.
  - Adds loader unlocks to the matching `nullius-logistics-*` technologies.
  - Keeps beltboxes visible and reachable through `deadlock-stacking-*` technologies.
- Linked Chest And Pipe:
  - Makes `Oem-linked-chest` visible and enabled under Nullius.
  - Unlocks linked chest, huge linked chest, share network output, and linked pipe recipes.
  - Places the technology directly after `nullius-geology-1`.
  - Sets the technology to require only `nullius-geology-pack`.
- WideChests Logistic:
  - Fixes the prototype error where an entity can require more items to place than the source item's stack size.
  - Handles both `placeable_by` and `items_to_place_this`.

## Installation

Put the packaged zip into your Factorio mods folder and enable `sanchei-nullius-compat-fixes`.

Disable the old split local fixes if you still have them installed:

- `entangled-belts-nullius-fix`
- `deadlock-loaders-nullius-fix`
- `widechests-stacksize-fix`
- `sanchei-nullius-research-fix`

## Notes

This is a compatibility patch for an existing mod set. It does not replace Nullius, Entangled Belts, Deadlock Beltboxes & Loaders, Linked Chest And Pipe, or WideChests.
