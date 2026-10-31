# swift-library-template

GitHub template repository for the running libraries. This file and `scripts/bootstrap.sh` are deleted when a new library is bootstrapped.

## Placeholders

| Token | Replaced with | Example |
| --- | --- | --- |
| `LibraryTemplate` | Module name, in contents and file names | `GPXSwift` |
| `library-template` | Repository name | `gpx-swift` |
| `__OWNER__` | GitHub username | |
| `__YEAR__`, `__COPYRIGHT_HOLDER__` | LICENSE | |

`LibraryTemplate` is a valid Swift name, so the template itself builds and tests as a normal package.

## One-time setup (in Xcode, before marking as template)

1. Xcode → File → New → Project → Multiplatform → App. Product name `LibraryTemplateDemo`, save inside `Demo/`, no Git repo.
2. In the project, File → Add Package Dependencies → Add Local… → select the repo root. Add the `LibraryTemplate` product to the app target.
3. Product → Scheme → Manage Schemes → tick **Shared** for `LibraryTemplateDemo`, so the scheme is committed.
4. Build and run on an iOS simulator and on macOS. Commit.
5. On GitHub: Settings → tick **Template repository** (or `gh repo edit --template`).

## Creating a library

Use `platform/scripts/create-library.sh`. It creates the repo from this template, runs `scripts/bootstrap.sh`, pushes, and applies repo settings.
