
# Contributing to mescat

Thank you for your interest in contributing! This document explains the preferred workflow for reporting issues, proposing changes, and submitting code to this Flutter/Dart project.

## Quick start

- Open an issue first to discuss larger features or breaking changes.
- Fork the repository and create a branch from `main` for your work.
- Make small, focused commits with clear messages.
- Run the analyzer, formatter and tests locally before opening a pull request.

## Branching & commits

- Create branches with descriptive names, e.g. `fix/login-button`, `feat/chat-history`, or `chore/deps`.
- Use imperative, short commit messages and include a longer description in the commit body if needed. Example:

	feat: add message retry button

	This adds a retry button to failed messages and updates the UI tests.

## Reporting issues

- Use the repository Issues tab to report bugs or request features.
- Provide a clear title, steps to reproduce, expected vs actual behavior, and any logs/screenshots.
- If you can, include a minimal reproduction (a small snippet or steps to reproduce in the app).

## Pull request process

1. Make sure your changes are on a branch forked from `main`.
2. Keep PRs focused and include a clear description of what changed and why.
3. Reference related issue numbers using `#<issue-number>`.
4. Run the analyzer, formatter and relevant tests locally (commands below).
5. CI will run on the PR — address review comments and fix any failing checks.

## Local setup & useful commands

This project is a Flutter app. The following commands assume you have Flutter installed and available on your PATH. They are written for PowerShell on Windows.

Install dependencies:

```powershell
flutter pub get
```

Format code:

```powershell
flutter format .
```

Run the analyzer:

```powershell
flutter analyze
```

Run unit & widget tests:

```powershell
flutter test
```

Run a single test file:

```powershell
flutter test test/widget_test.dart
```

Run the app on a connected device or emulator:

```powershell
flutter run
```

If you're working with platform-specific code (Android / iOS / Windows), open the appropriate folder in Android Studio or Xcode to build and debug native code.

## Style and linting

- Follow Dart and Flutter style guides. The project includes `analysis_options.yaml` — please run `flutter analyze` and fix reported issues before submitting.
- Keep public APIs stable and document exported members where appropriate.

## Tests

- Add unit and widget tests for new features and bug fixes where practical.
- Keep tests fast and deterministic. Use mocks for external services where possible.

## Commit checklist

- [ ] Code builds and runs locally
- [ ] Analyzer reports no new issues
- [ ] Code is formatted (`flutter format`)
- [ ] Relevant tests added and passing
- [ ] PR description explains the change and links related issues

## Code of conduct and license

By contributing you agree to follow the repository's code of conduct. This project is licensed under the MIT License — see `LICENSE.txt` for details.

## Need help?

Open an issue or contact the maintainers via the repository. Thank you for helping improve mescat!

