# RS Base Scanner ([Factorio mod](https://mods.factorio.com/mod/rs-base-scanner))

This mod scans a selected area of your base for some common issues/mistakes. Select an area with the *button in your toolbar* or *Ctrl+S* and let the tool do its magic. The issues will be marked in the world and optionally also on the map.

**Currently detected issues:**

- Backwards transport belts / underground belts / loaders.
- Belts that are slower than their inputs (only partially enabled by default, see settings).
- Beacons lacking some modules.
- Crafting machines lacking some productivity 3 modules (this does not account for availability of these or mods adding better modules yet).
- Crafting machines trying to craft more than 1 recipe per tick (>60/sec), which is impossible (this will usually only occur with mods enabling greater speeds).
- Loaders (in modded Factorio) that have some stray items on them that cannot be inserted into machine they are pointing towards.

Each can be disabled via the per player mod settings menu.

I plan on adding some more issues that it can detect. If you have any suggestions, let me know!

![Demo](https://assets-mod.factorio.com/assets/41f5e6626ea708fa7b6906d1245a398928defae2.png)
![Map markers](https://assets-mod.factorio.com/assets/a52eb0b17450aff8666697fc0cc8b0e9d4b03b0a.png)

(Mod used for machine & belts in the screenshot is Krastorio 2.)
