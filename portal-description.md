# Nullius Compat Fixes

Compatibility fixes for a Nullius 2.0 mod set.

This mod keeps a few optional QoL/content mods usable in a Nullius playthrough without bundling or redistributing those mods.

## Current fixes

- Entangled Belts:
  - Creates missing recipes for entangled Nullius underground belts.
  - Adds entangled belt recipes to `nullius-logistics-1` through `nullius-logistics-4`.
  - Removes unlock effects that point to missing recipes.
- Linked Chest And Pipe:
  - Adds a visible technology after `nullius-geology-1`.
  - Uses only `nullius-geology-pack` for the technology cost.
  - Migrates existing saves from the original hidden/internal technology.
  - Keeps optional non-recipe technology effects, including player enhancement effects.
  - Replaces vanilla plate ingredients with Nullius materials and removes `copper-plate`.
  - Uses Nullius-compatible pipe-to-ground ingredients for linked pipe recipes.
- Loaders Modernized:
  - Unlocks `mdrn-loader`, `mdrn-fast-loader`, and `mdrn-express-loader` through Nullius logistics technologies.
  - Migrates already researched saves so loader recipes become available immediately.
  - Replaces hidden vanilla loader ingredients with Nullius-compatible materials and inserters.
  - Keeps loader items in the logistics group.
- WideChests Logistic:
  - Fixes stack-size prototype errors caused by very large warehouse placeable counts.
- Quality of Life Research:
  - Replaces vanilla science pack costs with Nullius science packs.
  - Replaces hidden vanilla science pack prerequisites with matching Nullius technologies.

## Notes

This is a compatibility patch for an existing mod set. It does not replace Nullius, Entangled Belts, Loaders Modernized, Linked Chest And Pipe, WideChests, or Quality of Life Research.
