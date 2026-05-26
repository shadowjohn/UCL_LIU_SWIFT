# UCL_LIU_SWIFT Blueprint Design

Date: 2026-05-26
Status: Ready for user review

## Goal

UCL_LIU_SWIFT is a native macOS version of the Feimi input method. It preserves the typing habits, retro candidate UI, dictionary conversion workflow, pinyi behavior, simplified/traditional toggles, and command style of UCL_LIU and UCL_LIU_CSharp.

This project does not use Rime. The macOS input method and UI are the shell; Feimi Core is the input-method brain.

Version `0.01` must be usable for daily typing. It is not a skeleton release.

## Reference Sources

- `D:\GD\UCL_LIU`: primary reference for the complete Python workflow, including dictionary detection/conversion, pinyi loading, zhuyin mode, same-sound lookup, command handling, and reverse lookup.
- `D:\mytools\UCL_LIU_CSharp`: reference for the simplified Windows behavior, command processor shape, config defaults, and `liu.json` lookup flow.
- `y1lichen/ilimi-inputmethod`: reference for native macOS InputMethodKit structure, event handling, candidate window behavior, app-switch cleanup, user data folder, and installer workflow.

Reference code should be studied for behavior and architecture. Do not copy incompatible licensed source into this repository without a deliberate license review.

## Product Direction

The app should feel like Feimi, not like a generic macOS candidate panel.

- Native macOS input method built with Swift, AppKit, and InputMethodKit.
- Retro small floating candidate window, with dark background and bright text.
- AppKit first for candidate UI and window control.
- SwiftUI may be used later for installer/settings screens, but not for the first candidate window path.
- First core implementation is Swift.
- Future cross-platform work can extract the core to C++ or another shared library, but `0.01` should prioritize a reliable macOS release.

## Version 0.01 Scope

Version `0.01` must support:

- Installable macOS input method app that appears in system input sources.
- Keyboard event handling through `IMKInputController`.
- Composing buffer for Feimi codes.
- Candidate lookup from memory.
- Retro candidate window.
- Space commits the first candidate.
- Number keys select candidates.
- Enter commits the raw code.
- Esc clears composition.
- Backspace deletes the previous code unit.
- Candidate display uses the old `0肥 1飛 2非 ...` style by default.
- Feimi auxiliary selection behavior such as `v/r/s/f` when it matches the old behavior.
- Built-in `pinyi.txt` for same-sound and zhuyin lookup.
- Same-sound lookup using the old leading apostrophe flow, for example `'pns`.
- Zhuyin mode using `';`.
- Simplified/traditional toggle.
- Width and zoom commands.
- Lock/unlock game mode commands.
- Version command.
- `,,,z`: selected article/text to Feimi codes.
- `,,,x`: selected Feimi codes back to article/text.
- Logging, crash protection, and state reset.

The following are not required for `0.01`:

- AI association, cloud dictionary, sync, or large-model features.
- Full custom phrase UI.
- Polished installer UX beyond a workable install/build flow.
- Sound effects are in scope later; `wavs/` is committed as shared project audio assets.

## Repository Resource Policy

`pinyi.txt` may be committed and shipped as a built-in resource.

`liu-uni.tab` is copyrighted user-provided material and must not be committed. The app may read it from the user's Application Support folder or another explicit local import path.

`liu.json` and `liu.cin` should also be treated carefully when produced from user-provided copyrighted sources. Development tests should use tiny synthetic fixtures, not the full proprietary dictionary.

`wavs/` is committed as shared project audio assets for future sound effects.

## Architecture

The system has three major areas.

### macOS Shell

The shell is the native input method app.

Responsibilities:

- Own `IMKServer`, `IMKInputController`, lifecycle callbacks, and client communication.
- Receive keyboard events.
- Ignore command/control/option shortcuts so system and app shortcuts keep working.
- Set marked text and commit text to the active client.
- Reset composition when the input method deactivates, the client changes, or the candidate window closes.
- Host the status menu and user commands such as opening the settings folder and reloading dictionaries.

### Feimi Core

Feimi Core owns input-method behavior independent of AppKit.

Core modules:

- `FeimiEngine`: composing buffer, mode state, candidate lookup, commit decisions, paging state, and reverse lookup entry points.
- `FeimiDictionary`: in-memory dictionary, lookup by code, reverse lookup by character/text, and candidate ordering.
- `DictionaryPipeline`: detects and converts `liu-uni.tab`, `liu.cin`, and `liu.json`.
- `LiuTabConverter`: converts `liu-uni.tab` to `liu.cin`.
- `CinParser`: parses `%chardef begin` to `%chardef end`.
- `JsonDictionary`: loads and writes the `liu.json` shape used by UCL_LIU: `{ "chardefs": { "code": ["字", ...] } }`.
- `PinyiEngine`: parses `pinyi.txt`, builds zhuyin lookup tables, same-sound lookup, and reverse pronunciation data.
- `CommandProcessor`: detects and executes `,,,` commands.
- `FeimiConfig`: user settings such as mode, width, zoom, candidate count, and log level.

Feimi Core must be testable without InputMethodKit.

### App Data

Use:

```text
~/Library/Application Support/UCL_LIU_SWIFT/
```

Expected contents:

```text
liu.json
liu.cin
liu-uni.tab
pinyi.txt
config.json
user_phrase.json
theme.json
log/
```

The bundled `pinyi.txt` should be copied or loaded as a default. User-provided files in Application Support should override bundled defaults when appropriate.

## Dictionary Startup Flow

Startup must prepare the dictionary before normal key handling.

Order:

1. If `liu.json` exists, load it.
2. Else if `liu.cin` exists, convert it to `liu.json`, then load the JSON.
3. Else if `liu-uni.tab` exists, convert it to `liu.cin`, convert that to `liu.json`, then load the JSON.
4. Else show a clear error and log the missing dictionary state.

The conversion process may run during app/input method startup or explicit reload. It must not run inside the per-key event path.

After loading, candidate lookup uses memory only:

```swift
[String: [Candidate]]
```

Dictionary conversion should write cache files only to Application Support, not into the app bundle.

## Pinyi And Zhuyin

The first line of current `pinyi.txt` is `VERSION_0.01`. The next two lines define the key index and zhuyin symbols. Later lines map pronunciation keys to candidate characters.

`PinyiEngine` must support:

- Same-sound lookup from a typed candidate, preserving old UCL_LIU ordering behavior as much as possible.
- Zhuyin key-to-symbol conversion.
- Zhuyin symbol-to-key conversion.
- Reverse pronunciation table for showing pronunciation hints later.

Same-sound flow:

1. User types an apostrophe-prefixed Feimi code, such as `'pns`.
2. Engine first resolves the base target.
3. Space or selection opens same-sound candidates.
4. Candidate list is deduplicated and paged.

Zhuyin flow:

1. User types `';`.
2. Engine enters zhuyin mode and clears the normal composing buffer.
3. Subsequent zhuyin keys produce zhuyin-marked composing text and candidates.
4. Commit exits zhuyin mode.
5. Esc or empty backspace exits zhuyin mode.

## Command Processor

Version `0.01` supports:

```text
,,,unlock
,,,lock
,,,version
,,,c
,,,t
,,,s
,,,l
,,,+
,,,-
,,,z
,,,x
```

Command detection should live in `CommandProcessor`, not directly in the AppKit controller. The input controller passes text events to Feimi Core; the core returns either an input update, a commit request, a UI command, or a system operation request.

Command side effects:

- `,,,unlock`: normal typing mode.
- `,,,lock`: game mode, letting regular keys pass through.
- `,,,version`: show version/about notification.
- `,,,c`: simplified output mode.
- `,,,t`: traditional output mode.
- `,,,s`: narrower candidate UI.
- `,,,l`: wider candidate UI.
- `,,,+`: larger candidate UI.
- `,,,-`: smaller candidate UI.
- `,,,z`: selected article/text to Feimi codes.
- `,,,x`: selected Feimi codes back to article/text.

## Reverse Lookup Commands

`0.01` includes `,,,z` and `,,,x`.

These commands are high-risk but not blockers. The implementation should prefer native text-input APIs before falling back to pasteboard automation.

Preferred strategy:

1. Use the current IME client/text input client to inspect the selected range when available.
2. Read selected text through text-input client substring APIs when available.
3. Replace selected text through `insertText` with a replacement range when available.
4. Fall back to simulated copy/paste plus `NSPasteboard` only when direct text-client access is unavailable or unreliable in the target app.
5. If fallback automation needs macOS permissions, show a clear permission message and log the failure.

``,,,z``:

1. Capture selected text from the active app.
2. Preserve the user's current clipboard as much as possible.
3. If needed, convert simplified text to traditional before reverse lookup.
4. Use `FeimiDictionary.reverseLookup` to convert characters to preferred Feimi codes.
5. Insert or paste the converted code text back into the active app.
6. Restore clipboard content when possible.
7. Log failures without crashing the IME.

``,,,x``:

1. Capture selected Feimi code text from the active app.
2. Preserve the user's current clipboard as much as possible.
3. Parse codes and convert them to article/text using Feimi Core lookup.
4. Insert or paste converted text back into the active app.
5. Restore clipboard content when possible.
6. Log failures without crashing the IME.

macOS risk:

- Reading the active selection and simulating copy/paste may require Accessibility and/or Input Monitoring permission.
- Programmatic general pasteboard access may ask the user for permission on modern macOS.
- The app must detect permission failure and explain what the user needs to allow.
- Clipboard restoration is best effort. Failures must be logged.
- The first target is reliable behavior in common text clients; broader app compatibility can improve after `0.01`.

## Candidate UI

The candidate UI should be a small AppKit floating window with a Feimi retro style.

Required information:

- Current composing code.
- Candidate list in old numeric style, defaulting to `0候選 1候選 ...`.
- Mode flags: traditional/simplified, lock/normal, zhuyin, same-sound.

Required commands:

- `,,,s` narrows the window.
- `,,,l` widens the window.
- `,,,+` increases scale.
- `,,,-` decreases scale.

UI settings persist to `config.json`.

Do not use the default white macOS candidate window as the primary UI if it prevents the Feimi visual style. It is acceptable to study `IMKCandidates` behavior from ilimi, but `0.01` should favor a custom AppKit candidate window if needed for style and command control.

## Event Handling

`InputController` should handle:

- `keyDown`
- relevant `flagsChanged` events when needed for mode state
- activation/deactivation cleanup
- candidate selection
- app/client switching

Normal key flow:

```text
keyDown
-> ignore system shortcuts/modifiers
-> pass key to FeimiEngine
-> receive EngineResult
-> update composing text and candidate window
-> commit text if requested
-> log nonfatal errors
```

Special keys:

- Space: commit first candidate or advance same-sound paging when in that flow.
- Number: select visible candidate.
- Enter: commit raw code.
- Esc: clear composition.
- Backspace: delete previous composing unit; exit mode if empty.

## Error Handling And Logging

Logging path:

```text
~/Library/Application Support/UCL_LIU_SWIFT/log/uclliu_yyyyMMdd.log
```

Log categories:

- startup
- dictionary detection
- dictionary conversion
- dictionary parse failure
- pinyi parse failure
- IME event errors
- candidate window errors
- command errors
- reverse lookup and clipboard failures
- permission failures

Typing must remain responsive after nonfatal errors. The IME should clear unsafe state instead of crashing.

## Testing And Acceptance

Core tests:

- `liu.cin` parse.
- synthetic `liu-uni.tab` conversion fixture or parser-level binary fixture.
- `liu.json` load.
- lookup by code.
- candidate ordering.
- `v/r/s/f` auxiliary selection behavior.
- reverse lookup by character and article.
- `pinyi.txt` parse.
- same-sound lookup.
- zhuyin lookup.
- simplified/traditional mode behavior.
- command parsing.

IME/manual acceptance for `0.01`:

- TextEdit can input Chinese.
- Safari address/search field does not crash or lose state.
- Chrome input fields work.
- VS Code editor works.
- Terminal works.
- Candidate window follows the active insertion point closely enough to type normally.
- Switching apps clears stale composing buffer.
- Lock/unlock works.
- Simplified/traditional toggles work.
- UI width and zoom commands persist.
- `,,,z` works in TextEdit.
- `,,,x` works in TextEdit.
- Permission failure for `,,,z` / `,,,x` is understandable and logged.

## Version Roadmap

### 0.01 Daily Typing MVP

Deliver native macOS Feimi typing with full core behavior listed above.

### 0.02 Packaging And Import Polish

Improve installer, import UI, reload flow, and user-facing setup guidance.

### 0.03 User Phrases And Settings UI

Add user phrase management, richer config UI, theme editing, and sound options.

### 0.04 Clipboard/Reverse Lookup Hardening

Broaden `,,,z` / `,,,x` support across more apps, improve permission diagnostics, and refine clipboard restoration.

### Future Cross-Platform Core

Extract Feimi Core into a shared library only after the Swift core behavior is stable and covered by tests.

## Settled Decisions

The following choices are intentionally fixed for `0.01`:

- No Rime.
- Swift/AppKit/InputMethodKit.
- AppKit candidate UI.
- `pinyi.txt` built in.
- `liu-uni.tab` never committed.
- `wavs/` committed as project audio assets.
- `,,,z` and `,,,x` included in `0.01`.

No unresolved product decision blocks implementation planning.
