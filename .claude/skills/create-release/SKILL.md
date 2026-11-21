---
name: create-release
description: Create a new SemVer release of this library through the Release workflow.
disable-model-invocation: true
---

<!-- Synced from ios-platform (platform/templates/sync). Edit it there, not here. -->

A release is a manual run of the `Release` workflow on `main`. It runs full CI, computes the
next version from the latest tag, and creates the tag and the GitHub Release with generated
notes (REL-1 to REL-3). Swift Package Index then builds the docs for the new tag. Your job is
to pick the right bump, get the human's confirmation, and watch the run through. Needs `gh`,
authenticated.

## Steps

1. **Check `main`.** `git fetch --tags origin`, then confirm the latest CI run on `main` is
   green: `gh run list --branch main --workflow CI --limit 1`. Done when it shows success.
2. **List what is unreleased.** Find the latest tag
   (`git tag --list | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1`; none means the
   first release, `0.1.0` from a `minor` bump) and the PRs merged since it:
   `git log --oneline <tag>..origin/main`. Done when every commit maps to a merged PR. If
   there are none, stop: there is nothing to release.
3. **Pick the bump** (REL-4):
   - `major`: a breaking change (`!` in a PR title) at 1.0 or later.
   - `minor`: a new feature (`feat:`), or a breaking change while on 0.x.
   - `patch`: fixes and internal changes only.
4. **Check the notes.** Release notes are the PR titles. Point out any title that would read
   poorly in the notes, so the human can edit it on GitHub before the release.
5. **Confirm with the human.** Show the current version, the proposed next version, the bump
   and the PR list. Wait for an explicit yes.
6. **Run it:** `gh workflow run release.yml --ref main -f bump=<bump>`, then follow it with
   `gh run watch` on the new run. Done when the run succeeds.
7. **Verify:** `gh release view <version>` shows the release on the expected commit. Report
   the release URL.

If the run fails, report the failing job and its log (`gh run view <id> --log-failed`). The
workflow creates the tag and the release in one step, so a failed run leaves nothing to clean
up; fix the cause and run it again.
