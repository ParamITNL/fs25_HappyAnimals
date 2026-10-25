# Changelog

All notable changes to HappyAnimals are documented in this file.

## 1.0.0.0 - 2026-10-25

Initial Farming Simulator 25 development version.

### Added

- Automatic daily care for animal husbandries owned by the current farm.
- Configurable helper start time from `08:00` through `23:00`, with `09:00` as the default.
- Automatic filling of supported animal food groups.
- Automatic water supply for husbandries without an automatic water source.
- Optional straw supply.
- Horse training, fitness improvement, and cleaning.
- Food and straw pricing based on the in-game economy.
- Fixed horse-care pricing based on missing riding and fitness percentages.
- Animal upkeep charges applied to the current farm.
- Enable/disable action bound to `Left Ctrl` + `Left Alt` + `9` by default.
- Settings dialog bound to `Left Ctrl` + `Left Alt` + `0` by default.
- Per-savegame settings stored in `happyAnimals.xml`.
- Debug logging and the `haRunHelpers` console command.
- English, Dutch, French, and Spanish localization.
- FS25 mod descriptor, icon, GUI, and script integration.

### Known limitations

- This is a personal development build and should be considered untested for normal gameplay.
- Multiplayer support is disabled.
- Feed is purchased directly instead of being taken from farm storage.
- Fill types are not selected by price.
