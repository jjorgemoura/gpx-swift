# ``GPXSwift``

Read and write GPX files: waypoints, routes, tracks, metadata and vendor extensions.

## Overview

GPXSwift parses GPX 1.1 and GPX 1.0 into plain value types and writes them back as GPX 1.1.
It depends only on Foundation, so it also builds on Linux.

```swift
let document = try GPXDocument(contentsOf: fileURL)

for track in document.tracks {
    print(track.name ?? "Untitled", track.points.count)
}

try document.write(to: outputURL)
```

The reader is strict about structure and coordinates and lenient about everything else. A point
without a valid `lat` and `lon` throws a ``GPXError``, while an unparseable optional value, such
as a malformed `<time>`, is dropped. Vendor data inside `<extensions>`, for example Garmin heart
rate and cadence, is kept as a ``GPXExtension`` tree and survives a round trip.

## Topics

### Reading and writing

- ``GPXDocument``
- ``GPXError``

### Content

- ``GPXMetadata``
- ``GPXWaypoint``
- ``GPXRoute``
- ``GPXTrack``
- ``GPXTrackSegment``

### Supporting types

- ``GPXPerson``
- ``GPXEmail``
- ``GPXCopyright``
- ``GPXLink``
- ``GPXBounds``
- ``GPXFix``
- ``GPXExtension``
