# FS25 HappyAnimals

> [!WARNING]
> This initial release has not yet been verified through an in-game smoke test. Keep savegame backups. The mod is ported from the [FS22 AnimalHelper](https://github.com/ParamITNL/fs22-AnimalHelperMod) using AI.

HappyAnimals automatically tends to animal husbandries owned by the current farm. It is the Farming Simulator 25 successor to [FS22 AnimalHelper](https://github.com/ParamITNL/fs22-AnimalHelperMod).

The helper works once per day at a configurable time (`09:00` by default). It:

- Fills animal feed with the most effective available food, using the lowest current market price as the tie-breaker.
- Supplies water when the husbandry does not have an automatic water supply.
- Supplies straw when enabled.
- Trains and cleans horses.
- Skips husbandries owned by other farms.
- Does not run while the player is sleeping.

## Costs

HappyAnimals first takes suitable feed from storage owned by the current farm, without charging for it. When that stock cannot fill the husbandry, the helper buys the remainder at the current price reported by the in-game economy. Stored and purchased feed are both selected by effectiveness first, then by lowest market price.

Purchased feed and supplied straw are charged to the current farm as animal upkeep. Horse training and fitness use a fixed price per missing percentage point. Water is supplied without a material charge.

## Installation on Windows

1. Download `FS25_HappyAnimals.zip` from the [latest GitHub release](https://github.com/ParamITNL/fs25_HappyAnimals/releases/latest).
2. Copy the ZIP file as-is into:
   ```text
   %USERPROFILE%\Documents\My Games\FarmingSimulator2025\mods
   ```
3. Do not extract the ZIP file.
4. Start Farming Simulator 25 and enable HappyAnimals for the savegame.

The release archive has the required FS25 mod folder layout at its root.

## Usage

| Action | Default keyboard binding |
|---|---|
| Enable or disable the animal helpers | `Left Ctrl` + `Left Alt` + `9` |
| Open the HappyAnimals settings | `Left Ctrl` + `Left Alt` + `0` |

Bindings can be changed through the Farming Simulator controls menu.

## Settings

Settings are stored per savegame in `happyAnimals.xml`.

- **Start time** — Hour at which the helpers perform their daily work. Available from `08:00` through `23:00`.
- **Supply straw** — Determines whether the helpers fill straw in supported husbandries.
- **Debug mode** — Writes additional information to the FS25 log and allows the helpers to run every hour.

When debug mode is enabled, the `haRunHelpers` console command runs the helpers immediately.

## Multiplayer

Multiplayer support is disabled. The mod is intended for personal single-player use and has not been designed or tested for multiplayer synchronization.

## Languages

- English
- Dutch
- French
- Spanish

## Development status

Version `1.0.0.0` is the initial public release. It has not yet been verified in game, so there is no guarantee of correct pricing, compatibility with every husbandry, or compatibility with other mods.

Potential future improvements carried over from the FS22 project include determining straw use from husbandry capabilities automatically and adding more translations. These items are ideas, not commitments or a release schedule.

## Changelog

See [changelog.md](changelog.md) for the complete version history.

## License

HappyAnimals is available under the [MIT License](LICENSE).
