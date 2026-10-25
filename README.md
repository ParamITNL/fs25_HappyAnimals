# FS25 HappyAnimals

> [!WARNING]
> This mod is developed for my own use. It is still in a developmental stage and should be considered completely untested for normal gameplay. It may contain errors, affect savegames, or behave differently than expected. Use it at your own risk and keep savegame backups.

HappyAnimals automatically tends to animal husbandries owned by the current farm. It is the Farming Simulator 25 successor to [FS22 AnimalHelper](https://github.com/ParamITNL/fs22-AnimalHelperMod).

The helper works once per day at a configurable time (`09:00` by default). It:

- Fills the available food groups using supported fill types.
- Supplies water when the husbandry does not have an automatic water supply.
- Supplies straw when enabled.
- Trains and cleans horses.
- Skips husbandries owned by other farms.
- Does not run while the player is sleeping.

## Costs

HappyAnimals uses the in-game economy to calculate the cost of supplied food and straw. Horse training and fitness use a fixed price per missing percentage point. Water is supplied without a material charge.

Costs are charged to the current farm as animal upkeep.

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

Potential future improvements carried over from the FS22 project include:

- Taking feed from farm storage before buying it.
- Selecting fill types based on price.
- Determining straw use from husbandry capabilities automatically.
- Additional translations.

These items are ideas, not commitments or a release schedule.

## Version history

- **1.0.0.0** — Initial Farming Simulator 25 conversion.

## License

HappyAnimals is available under the [MIT License](LICENSE).
