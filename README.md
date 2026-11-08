# GPXSwift

A library for reading and writing GPX files, with plain Swift value types.

[![Documentation](https://img.shields.io/badge/documentation-gray?logo=swift&logoColor=white)][docs]
[![CI](https://github.com/jjorgemoura/gpx-swift/actions/workflows/ci.yml/badge.svg)](https://github.com/jjorgemoura/gpx-swift/actions/workflows/ci.yml)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjjorgemoura%2Fgpx-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/jjorgemoura/gpx-swift)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjjorgemoura%2Fgpx-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/jjorgemoura/gpx-swift)

  * [Overview](#overview)
  * [Quick start](#quick-start)
  * [Examples](#examples)
  * [Documentation](#documentation)
  * [Installation](#installation)
  * [Community](#community)
  * [License](#license)

## Overview

<!-- TODO: Why GPXSwift exists and what makes it different. Two or three short paragraphs. -->

GPXSwift parses GPX 1.1 and GPX 1.0 into value types and writes them back as GPX 1.1. It depends
only on Foundation, so it also builds on Linux.

<!-- TODO: Short bullet list of the main ideas, e.g.:
  * Strict where it matters, lenient everywhere else.
  * Vendor extensions survive a round trip.
  * Plain value types: Sendable, Hashable and Codable.
-->

## Quick start

```swift
import GPXSwift

let document = try GPXDocument(contentsOf: fileURL)

for track in document.tracks {
  print(track.name ?? "Untitled", track.points.count)
}

try document.write(to: outputURL)
```

<!-- TODO: Walk through the other common tasks, each with a short snippet:
  * Reading from a string or `Data`.
  * Handling `GPXError`.
  * Building a document from scratch.
  * Reading vendor extensions (for example Garmin heart rate).
-->

## Examples

This repo includes a demo app in [`Examples/`](Examples) that exercises the library. Run
`make demo` to open it.

<!-- TODO: Link to larger examples or sample projects once they exist. -->

## Documentation

The latest documentation for GPXSwift's APIs is available [here][docs].

<!-- TODO: Link to the main DocC articles once they are written. -->

## Installation

You can add GPXSwift to an Xcode project by adding it as a package dependency.

> https://github.com/jjorgemoura/gpx-swift

If you want to use GPXSwift in a [SwiftPM](https://swift.org/package-manager/) project, it's as
simple as adding it to your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/jjorgemoura/gpx-swift", from: "0.0.1")
]
```

And then adding the product to any target that needs access to the library:

```swift
.product(name: "GPXSwift", package: "gpx-swift"),
```

## Community

If you want to discuss this library or have a question about how to use it to solve a particular
problem, the [discussions](https://github.com/jjorgemoura/gpx-swift/discussions) tab of this repo
is the best place to start. Bugs and feature requests go in
[issues](https://github.com/jjorgemoura/gpx-swift/issues).

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

[docs]: https://swiftpackageindex.com/jjorgemoura/gpx-swift/documentation/gpxswift
