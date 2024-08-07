# RS Base Scanner ([Factorio mod](https://mods.factorio.com/mod/rs-base-scanner))

This mod scans a selected area of your base for some common issues/mistakes. Select an area with the *button in your toolbar* or *Ctrl+S* and let the tool do its magic. The issues will be marked in the world and optionally also on the map.

Note that scanning large areas will lag the game for a couple of seconds.

**Currently detected issues:**

- Backwards transport belts / underground belts / loaders.
- Belts that are slower than their inputs (only partially enabled by default, see settings) (may have some bugs).
- Beacons lacking some modules.
- Beacons affecting no machines.
- Crafting machines lacking some productivity modules (configurable).
- Crafting machines trying to craft more than 1 recipe per tick (>60/sec), which is impossible (this will usually only occur with mods enabling greater speeds).
- Assembling machines that have no recipe set.
- Crafting machines with missing fluid connections.
- Crafting machines with no power (default disabled) or low power.
- Loaders (in modded Factorio) that have some stray items on them that cannot be inserted into machine they are pointing towards.
- Damaged items clogging up machines.
- Orphan underground belts and pipes to ground, taking into account tileable builds.
- Orphan rail signals.
- Logistic chests that request too many items for their capacity.
- Accidentally unfiltered logistic storage chests.
- Ghosts outside of robot construction range.

Each can be disabled via the per player mod settings menu.

*If you have suggestions for more issues it could detect, let me know!*

![Demo](https://assets-mod.factorio.com/assets/6554d7591a30166ba58421483a20d45cb6faccc9.png)
![Map markers](https://assets-mod.factorio.com/assets/a52eb0b17450aff8666697fc0cc8b0e9d4b03b0a.png)

(Mod used for machine & belts in the screenshot is Krastorio 2.)
