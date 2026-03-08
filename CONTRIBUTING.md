# Contributing to TermKit

Thank you for your interest in contributing to TermKit!

## Development Setup

1. **Requirements:** macOS 13+ with Xcode Command Line Tools (Swift 5.9+)
2. Clone the repository:
   ```bash
   git clone https://github.com/MenheraHann/TermKit.git
   cd TermKit
   ```
3. Build and install:
   ```bash
   make install
   ```

## Project Structure

```
Sources/TermKit/
  TermKitApp.swift          # App entry point (menu bar)
  TermKitModel.swift        # Central config + coordinator
  Input/                    # Keyboard event detection (CGEventTap)
  Menu/                     # Menu state machine, coordinator, window, view
  Models/                   # Data models (config, CLI entries, etc.)
  Services/                 # Paste service, config store, image paste
  Views/                    # SwiftUI settings views
  L10n/                     # Localization (9 languages)
Resources/                  # Info.plist, CLI tool icons
```

## How to Contribute

### Reporting Bugs

- Use the [Bug Report](https://github.com/MenheraHann/TermKit/issues/new?template=bug_report.md) template
- Include your macOS version and TermKit version
- Describe steps to reproduce

### Suggesting Features

- Use the [Feature Request](https://github.com/MenheraHann/TermKit/issues/new?template=feature_request.md) template
- Explain the use case and expected behavior

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Test: `make install` and verify the app works
5. Commit with conventional commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`
6. Push and open a Pull Request

## Code Style

- Follow existing Swift conventions in the codebase
- Use `NSLog` for logging (not `print`)
- Add Chinese comments for key logic (the codebase uses Chinese documentation)
- Use `[weak self]` in all closures that capture self

## Localization

The app supports 9 languages via `L10n/L10n.swift`. When adding user-facing strings:
1. Add a new computed property to the appropriate `L10n` enum
2. Provide translations for all 9 languages
3. If unsure about a translation, add English as placeholder and note it in the PR
