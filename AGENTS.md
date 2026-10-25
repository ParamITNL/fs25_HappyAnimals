# Farming Simulator 25 Mod Worktree Guidance

## Scope

This worktree contains Farming Simulator 25 mods. Treat FS25 runtime behavior, GIANTS Engine constraints, multiplayer synchronization, and savegame compatibility as first-class requirements.

## Authoritative references

- Use the official [Farming Simulator 25 scripting documentation](https://gdn.giants-software.com/documentation_scripting_fs25.php) as the primary API reference.
- Confirm APIs against the documented FS25 Script, Engine, or Foundation version before using them. Do not assume an FS22 API or community example is still valid.
- Prefer an existing pattern in this worktree when it is compatible with the official FS25 API and the mod's current architecture.
- If documentation and observed game behavior disagree, record both and treat the observed FS25 log/runtime behavior as the implementation constraint.

## Repository discovery

Before editing:

1. Locate and read the mod's `modDesc.xml`.
2. Identify the scripts, XML files, translations, assets, and any referenced I3D files involved in the change.
3. Search for the affected specialization, event, callback, XML path, configuration key, and network state before changing a public contract.
4. Check sibling mods only for established local conventions; do not copy stale FS22 code blindly.

Do not guess file names, XML paths, node indices, specialization names, or callback signatures.

## Implementation rules

### Lua

- Match the surrounding Lua style and GIANTS class/specialization conventions.
- Keep global namespace additions to the minimum required by GIANTS registration APIs. Use locals for helpers and constants.
- Register event listeners, functions, overwritten functions, and XML schema paths in the appropriate GIANTS lifecycle hooks.
- Preserve the distinction between server-authoritative state, client presentation, and shared state.
- Guard optional objects and nodes when the engine can legitimately omit them; do not hide malformed required configuration with silent fallbacks.
- Avoid per-frame allocations and repeated XML, node, or table lookups in `update`, `draw`, and other hot callbacks. Cache stable values during load and release owned resources during delete.
- Use the game's logging facilities with a stable mod prefix. Remove temporary diagnostics before delivery unless they are intentional operator-facing errors or warnings.
- Do not introduce compatibility shims for obsolete internal APIs unless compatibility is an explicit requirement.

### Multiplayer and persistence

- Decide which side owns every mutable value. Gameplay-affecting state is normally server-authoritative.
- Synchronize state through the established event or stream mechanisms; never rely on both peers independently producing the same side effect.
- Verify join-in-progress behavior for synchronized state.
- For persisted values, update save/load handling together and preserve existing savegames unless the task explicitly requires a breaking migration.
- Keep event serialization order and data types identical between write and read paths.

### XML and `modDesc.xml`

- Keep XML well-formed and preserve the repository's formatting.
- Ensure every added script, specialization, store item, translation, icon, and dependency is declared where FS25 expects it.
- Update `descVersion` only when required by the target FS25 release; never guess its value.
- Register custom XML schema paths before reading them, using the documented FS25 schema APIs.
- Treat case and relative paths as portability-sensitive even when the current Windows filesystem accepts them.

### I3D and assets

- Avoid hand-editing large generated I3D data unless the change is small, understood, and reviewable.
- Keep node references consistent with the corresponding XML and scripts.
- Do not add unlicensed, uncompressed, or unused assets.
- Preserve texture and filename casing. Check that referenced files will be included in the packaged mod.

### Localization

- Add player-visible text through the mod's localization system, not as hard-coded Lua strings.
- Keep localization keys stable and update every language file already maintained by the mod.
- Use the repository's fallback-language convention when a translation is unavailable.

### Versioning and changelog

- Update `changelog.md` in the same change as every player-visible feature, behavior change, bug fix, compatibility change, or release.
- Add new release entries above older releases. Include the exact version, release date, and concise `Added`, `Changed`, `Fixed`, `Removed`, or `Known limitations` sections as applicable.
- Preserve published changelog history. Correct factual mistakes when necessary, but do not silently rewrite prior release notes.
- Every new release entry in `changelog.md` MUST have the same version number as the `<version>` value in `modDesc.xml`; update both files together.
- Use the four-component FS25 version format already used by the mod, such as `1.0.0.0`. Follow the repository's established increment convention; if none exists and the requested version is ambiguous, ask which release number to use.
- Do not confuse the mod's `<version>` with `descVersion`. The former is the mod release number; the latter is the FS25 descriptor schema version and changes only when the target game release requires it.
- Documentation-only or internal tooling changes do not require a mod version bump unless they are being published as a new mod release.

## Verification

For every behavioral change:

1. Validate all edited XML files with an XML parser.
2. Run the repository's existing lint, validation, packaging, or test commands when present.
3. Launch the mod in Farming Simulator 25 and exercise the changed path. Inspect the FS25 log for Lua errors, XML warnings, missing files, and synchronization errors.
4. For multiplayer-sensitive changes, test server and client behavior, including a client joining after state has changed.
5. For persistence changes, save, reload, and verify both new and representative existing save data.
6. Confirm the packaged mod uses the expected folder layout and contains every referenced file.

Tests and static checks do not replace an in-game smoke test. If FS25 cannot be launched in the current environment, report that limitation explicitly and provide the exact static checks completed.

## Change discipline

- Keep changes scoped to the requested behavior.
- Update affected call sites, configuration, translations, and documentation in the same change.
- Remove obsolete code and temporary files after a clean cutover.
- Do not commit generated logs, savegames, shader caches, editor backups, or packaged ZIP files unless the repository explicitly tracks them.
- Summarize verification with exact commands and the observed in-game scenario; never claim an unrun check.
