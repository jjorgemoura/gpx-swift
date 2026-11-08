<!-- BEGIN platform (synced, do not edit) -->
# Project rules (shared)

This block is synced from the `platform` repo. Edit it there, not here.
<!-- END platform -->

## GPXSwift

Swift library that reads GPX 1.1 and 1.0 files into value types and writes them back as GPX 1.1.
Foundation only, so it also builds on Linux.

### Layout
- `Sources/GPXSwift/Model/` is the public API: `GPXDocument` (entry point), `GPXTrack`,
  `GPXRoute`, `GPXWaypoint`, `GPXMetadata`, `GPXExtension` and the small supporting types.
  All are `Sendable, Hashable, Codable` structs.
- `Sources/GPXSwift/Internal/` is not public: `RawElement` and `TreeBuilder` (XML parsing),
  `GPXReader` (tree to model), `GPXWriter` (model to XML), `GPXDateCoding`.
- `GPXError` is the only error type thrown while reading.
- `Tests/GPXSwiftTests/Fixtures/` holds sample `.gpx` files. Name them for what they exercise.
- `Examples/DemoApp.xcodeproj` is the demo app.

### Behaviour to preserve
- Reading is strict about structure and coordinates: a missing or invalid `lat`/`lon`, a
  non-`<gpx>` root or malformed XML throws `GPXError`.
- Reading is lenient about everything else: an unparseable optional value, such as a bad
  `<time>`, is dropped instead of failing the file.
- Output is always GPX 1.1, even for 1.0 input. `version` keeps the input version.
- Extensions are a lossless tree (`GPXExtension`) and namespace prefixes are kept as written.
  `rootAttributes` keeps `xmlns:*` declarations so the prefixes stay valid after a write.
  Any change to the reader or writer must keep round trips lossless.
- Times without a zone are taken as UTC. Fractional seconds are written only when present.
- Public API needs doc comments, and the DocC catalog lives in `GPXSwift.docc`.

### Gotchas
- Build the demo through `GPXSwift.xcworkspace`, never `-project`. The project doesn't declare
  the package, so the `GPXSwift` product only resolves through the workspace.
- SwiftLint caches results locally, so a stale cache can hide violations that CI finds.
  `make lint` skips the cache. For Xcode, run `rm -rf ~/Library/Caches/SwiftLint`.
- The prebuilt SwiftLint binary needs `libxml2.so.2`, so the Linux lint job pins an Ubuntu
  Swift image instead of `swift:latest`. See the comment in `.github/workflows/ci.yml`.

### Verifying changes
- Run `make lint` and `make test` before pushing. The `Makefile` has the other targets.
- For anything the demo app touches, build the `DemoApp` scheme from the workspace for both
  iOS Simulator and macOS, and check that `make demo` still opens.
