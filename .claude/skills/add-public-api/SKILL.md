---
name: add-public-api
description: Use when adding, changing or removing public API in this library (a public type, method, property, initializer or protocol requirement).
---

<!-- Synced from ios-platform (platform/templates/sync). Edit it there, not here. -->

Public API is the contract consumers pin with SemVer. Every public symbol ships with its
documentation, tests and isolation decided. The rule IDs below are defined in `standards/` of
`jjorgemoura/ios-platform`; read the file for a rule whenever its intent is unclear.

## Steps

1. **Shape the surface.** Make the symbol `public` only if a consumer needs it; everything else
   stays `internal` or `package` (API-6). Follow the Swift API Design Guidelines (API-5).
   Done when every new `public` has a consumer use case you can state in one sentence.
2. **Keep the library independent.** New types belong to this library (API-2). A new
   dependency needs an ADR first (API-3), and never another library in this set (API-1).
   Location, microphone and speaker access goes through a protocol (API-4).
3. **Decide concurrency.** Public types are `Sendable`, or their DocC says why not (CONC-2).
   Every `@unchecked Sendable` carries a comment stating the invariant that makes it safe
   (CONC-3). The module stays nonisolated by default; mark isolation explicitly where a type
   needs it (CONC-4). Long-running work supports cancellation (CONC-6).
4. **Document.** Every public symbol has a DocC comment: summary, parameters, return value,
   thrown errors (DOC-1). A non-trivial feature also gets an article in the `.docc` catalog
   (DOC-5). Done when `make docs` passes, since it treats DocC warnings as errors.
5. **Test.** Cover every new public symbol with Swift Testing (TEST-1, TEST-3). Parsers get
   fixture files in `Tests/<Module>Tests/Fixtures/` (TEST-4); hardware-backed code is tested
   through a fake of its protocol (TEST-5).
6. **Show it in the demo** when it is a main feature (DEMO-4): build the `DemoApp` scheme from
   the workspace for iOS Simulator and macOS.
7. **Name the SemVer impact.** A removed or changed public symbol is breaking: it bumps the
   major version, or the minor while on 0.x (REL-4). Write the PR title as a Conventional
   Commit (`feat:` for additions, `feat!:` or `fix!:` for breaking changes) (GIT-3), because
   release notes are generated from PR titles.

## Done

`make lint`, `make test` and `make docs` all pass, and every step above is satisfied for every
public symbol you added or changed.
