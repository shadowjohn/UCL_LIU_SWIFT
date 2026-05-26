# Dictionary Import Design

Date: 2026-05-26
Status: Ready for user review

## Goal

Version `0.01` should let a first-time user provide a Feimi dictionary without knowing the internal Application Support path.

The app already supports the dictionary loading chain:

1. `liu.json`
2. `liu.cin`
3. `liu-uni.tab`

This design adds a macOS UI path for importing those files and reloading the input method. It does not bundle copyrighted dictionary material.

## Decision

Use manual import as the primary flow.

When no dictionary exists, show a first-run prompt with these choices:

- Select Dictionary File...
- Open User Folder
- Later

The tray menu should also expose dictionary actions:

```text
7.字根檔
  匯入字根檔...
  重新載入字典
  開啟使用者資料夾
```

The first `0.01` implementation will not scan official Boshiamy install locations. macOS Boshiamy ownership appears uncommon for the target user base, and the installed file paths are not stable enough to make that the first solution.

## Import Rules

The importer accepts:

- `liu-uni.tab`
- `.cin`
- `.json`

The selected file is copied into:

```text
~/Library/Application Support/UCL_LIU_SWIFT/
```

Destination names are normalized:

```text
liu-uni.tab -> liu-uni.tab
*.cin       -> liu.cin
*.json      -> liu.json
```

After a successful import, the app posts the existing reload notification so `FeimiInputController` reloads dictionary and pinyi data.

## Cache Behavior

The current loader behavior remains the source of truth:

- `liu.json` loads directly.
- `liu.cin` loads and writes `liu.json` cache.
- `liu-uni.tab` loads and writes `liu.cin` plus `liu.json` cache.

Generated cache files stay in Application Support. Nothing is written into the app bundle or repository.

If a user imports a lower-priority source after higher-priority files already exist, the importer must move the stale higher-priority files to a timestamped backup folder before reload:

- Importing `liu-uni.tab` backs up existing `liu.cin` and `liu.json`.
- Importing `.cin` backs up existing `liu.json`.
- Importing `.json` leaves other source files alone, but `liu.json` becomes the active dictionary because it has highest priority.

Backups should go under:

```text
~/Library/Application Support/UCL_LIU_SWIFT/Dictionary Backups/<timestamp>/
```

If the destination file already exists, back it up before replacing it with the newly selected file.

This keeps the priority chain predictable without deleting the user's original source.

## First-Run Prompt

`FeimiDataStore.loadDictionary()` currently returns an empty dictionary when no file is found. The new behavior should still avoid crashing, but it should also notify the UI layer that setup is incomplete.

The prompt should appear at most once per app launch while no dictionary is available. It should not appear on every keystroke or every failed load.

Recommended copy:

```text
肥米需要字根檔才能輸入中文。

請選取合法來源的 liu-uni.tab、liu.cin 或 liu.json，或稍後放到使用者資料夾。
```

Buttons:

```text
選取字根檔...
開啟使用者資料夾
稍後
```

## Components

Add a small macOS-side importer component, separate from `FeimiCore`:

- `FeimiDictionaryImportController`
  - Presents `NSOpenPanel`.
  - Filters allowed file extensions.
  - Creates Application Support directory.
  - Copies selected file to the normalized destination name.
  - Backs up stale higher-priority files according to import type.
  - Backs up any destination file before replacing it.
  - Posts `.feimiReloadData`.
  - Shows success or failure alert.

Keep `FeimiCore` focused on parsing and loading dictionaries. It should not depend on AppKit or know about `NSOpenPanel`.

## Error Handling

Handle these cases explicitly:

- User cancels file selection: do nothing.
- Unsupported extension: show a short error.
- Copy fails: show the system error.
- Reload still fails after copy: show that the file was copied but could not be loaded.

Do not log dictionary contents, selected text, or converted text. Logging paths and error metadata is acceptable.

## Testing

Core tests remain Linux/Docker friendly:

- Add tests for normalized import destination decisions in a pure Swift helper if practical.
- Keep parser and loader tests using synthetic fixtures only.
- Add source-level macOS metadata tests for menu labels if AppKit code cannot compile in Docker.

Manual macOS test checklist:

- Fresh install with no dictionary shows first-run prompt.
- Select `liu-uni.tab`, then verify typing and generated `liu.cin` / `liu.json`.
- Select `.cin`, then verify typing and generated `liu.json`.
- Select `.json`, then verify typing.
- Tray import works after the first-run prompt is dismissed.
- Reload menu still works.
- `liu-uni.tab` remains untracked by git.

## Future Work

Later versions can add:

- Multiple named dictionary profiles.
- A tray submenu for switching active dictionary profile.
- Search known Boshiamy install locations and offer import suggestions.
- Support for additional dictionary formats.
