# Dictionary Import Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let first-time macOS users import a legal Feimi dictionary file without manually finding the Application Support directory.

**Architecture:** Add a small Foundation-only import planning helper in `FeimiCore` for testable file rules, then add an AppKit controller in `macos/UCL_LIU_SWIFT` for `NSOpenPanel`, backups, copy, alert, and reload notification. `FeimiDataStore` will expose whether a dictionary is available and prompt once per app launch when missing.

**Tech Stack:** Swift 5.9, Foundation, AppKit, InputMethodKit, XCTest, existing shell build scripts.

---

### Task 1: Import Planning Helper

**Files:**
- Create: `Sources/FeimiCore/FeimiDictionaryImportPlan.swift`
- Test: `Tests/FeimiCoreTests/FeimiDictionaryImportPlanTests.swift`

- [ ] Write failing tests for accepted source filenames, destination names, stale cache backups, and unsupported extensions.
- [ ] Run `swift test --filter FeimiDictionaryImportPlanTests` and confirm failures are caused by the missing helper.
- [ ] Implement `FeimiDictionaryImportPlan` with `.json`, `.cin`, and `.tab` import kinds.
- [ ] Re-run the focused tests and confirm they pass.

### Task 2: macOS Import Controller

**Files:**
- Create: `macos/UCL_LIU_SWIFT/FeimiDictionaryImportController.swift`
- Modify: `macos/UCL_LIU_SWIFT/FeimiStatusMenu.swift`
- Test: `Tests/FeimiCoreTests/MacOSMetadataTests.swift`

- [ ] Write source-level metadata tests for the dictionary submenu, import action, open panel, backup folder, and reload notification.
- [ ] Run `swift test --filter MacOSMetadataTests` and confirm the new assertions fail before implementation.
- [ ] Implement `FeimiDictionaryImportController` with `NSOpenPanel`, normalized copy destination, timestamped backup folder, success/failure alerts, and `.feimiReloadData` post.
- [ ] Add tray submenu `7.字根檔` with import, reload, and open user folder actions.
- [ ] Re-run metadata tests and confirm they pass.

### Task 3: First-Run Missing Dictionary Prompt

**Files:**
- Modify: `macos/UCL_LIU_SWIFT/FeimiDataStore.swift`
- Modify: `macos/UCL_LIU_SWIFT/FeimiInputController.swift`
- Test: `Tests/FeimiCoreTests/MacOSMetadataTests.swift`

- [ ] Write source-level metadata tests proving `FeimiDataStore` can detect missing dictionaries and `FeimiInputController` prompts once.
- [ ] Run `swift test --filter MacOSMetadataTests` and confirm the new assertions fail.
- [ ] Add dictionary availability detection and a once-per-launch setup prompt with buttons for selecting a file, opening the user folder, or postponing.
- [ ] Re-run metadata tests and confirm they pass.

### Task 4: Documentation and Project Notes

**Files:**
- Modify: `README.md`
- Modify: `docs/macos_install_uninstall.md`
- Modify: `TODO.md`
- Modify: `history.md`

- [ ] Update user-facing docs to describe tray import and first-run prompt.
- [ ] Mark dictionary import work in `TODO.md`.
- [ ] Record the feature and any caveats in `history.md`.

### Task 5: Verification and Commit

**Files:**
- All changed files.

- [ ] Run focused Swift tests for the new helper and metadata tests.
- [ ] Run the full Swift test suite in Docker or local Swift.
- [ ] Check git status and ensure `liu-uni.tab`, `.build/`, and `.superpowers/` remain untracked.
- [ ] Commit the completed feature on `main`.
