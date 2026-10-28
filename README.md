# FS25 HappyAnimals

> [!WARNING]
> This mod is developed for my own use. It is still in a developmental stage and should be considered completely untested for normal gameplay. It may contain errors, affect savegames, or behave differently than expected. Use it at your own risk and keep savegame backups. It is ported from the [FS22 AnimalHelper](https://github.com/ParamITNL/fs22-AnimalHelperMod) using AI.

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

1. Open PowerShell or Windows Terminal.
2. Change to the Farming Simulator 25 mods directory:
   ```powershell
   cd "$HOME\Documents\My Games\FarmingSimulator2025\mods"
   ```
3. Clone this repository into the expected mod folder:
   ```powershell
   git clone https://github.com/ParamITNL/fs25_HappyAnimals.git FS25_HappyAnimals
   ```
4. Start Farming Simulator 25 and enable HappyAnimals for the savegame.

The repository already has the required FS25 mod folder layout; no build step is required for local use.

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

This repository contains development code rather than a tested release. There is no guarantee of savegame compatibility, correct pricing, compatibility with every husbandry, or compatibility with other mods.

Potential future improvements carried over from the FS22 project include determining straw use from husbandry capabilities automatically and adding more translations. These items are ideas, not commitments or a release schedule.

## Changelog

See [changelog.md](changelog.md) for the complete version history.

## License

HappyAnimals is available under the [MIT License](LICENSE).
