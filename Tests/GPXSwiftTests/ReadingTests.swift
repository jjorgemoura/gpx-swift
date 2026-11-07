import Foundation
import Testing

@testable import GPXSwift

@Suite("Reading GPX 1.1")
struct ReadingTests {
    @Test
    func minimalDocument() throws {
        let document = try TestHelpers.fixture("minimal")
        #expect(document.creator == "min")
        #expect(document.version == "1.1")
        #expect(document.metadata == nil)
        #expect(document.waypoints.isEmpty && document.routes.isEmpty && document.tracks.isEmpty)
    }

    @Test
    func metadata() throws {
        let metadata = try #require(try TestHelpers.fixture("full-1.1").metadata)
        #expect(metadata.name == "Morning & evening loop")
        #expect(metadata.description == "Every element of the GPX 1.1 schema")
        #expect(metadata.author?.name == "Jane Walker")
        #expect(metadata.author?.email?.address == "jane@example.com")
        #expect(metadata.author?.link == GPXLink(href: "https://example.com/jane", text: "Jane's page", type: "text/html"))
        #expect(metadata.copyright == GPXCopyright(author: "Jane Walker", year: 2026, license: "https://example.com/license"))
        #expect(metadata.links == [GPXLink(href: "https://example.com/loop", text: "The loop")])
        #expect(metadata.time == (try TestHelpers.date("2026-05-01T06:30:00Z")))
        #expect(metadata.keywords == "run, loop, test")
        #expect(metadata.bounds == GPXBounds(minLatitude: 38.70, minLongitude: -9.20, maxLatitude: 38.80, maxLongitude: -9.10))
        #expect(metadata.extensions.first?.name == "meta:note")
        #expect(metadata.extensions.first?.text == "kept")
    }

    @Test
    func waypointWithEveryField() throws {
        let waypoint = try #require(try TestHelpers.fixture("full-1.1").waypoints.first)
        #expect(waypoint.latitude == 38.7223)
        #expect(waypoint.longitude == -9.1393)
        #expect(waypoint.elevation == 12.5)
        #expect(waypoint.time == (try TestHelpers.date("2026-05-01T06:31:00.250Z")))
        #expect(waypoint.magneticVariation == 1.5)
        #expect(waypoint.geoidHeight == 50.2)
        #expect(waypoint.name == "Start")
        #expect(waypoint.comment == "comment")
        #expect(waypoint.description == "Where it begins")
        #expect(waypoint.source == "Handheld")
        #expect(waypoint.links == [GPXLink(href: "https://example.com/start")])
        #expect(waypoint.symbol == "Flag")
        #expect(waypoint.type == "Landmark")
        #expect(waypoint.fix == .threeD)
        #expect(waypoint.satellites == 9)
        #expect(waypoint.horizontalDilution == 0.9)
        #expect(waypoint.verticalDilution == 1.1)
        #expect(waypoint.positionDilution == 1.4)
        #expect(waypoint.ageOfDGPSData == 3.5)
        #expect(waypoint.dgpsStationID == 42)
    }

    @Test
    func nonASCIIText() throws {
        let document = try TestHelpers.fixture("full-1.1")
        #expect(document.waypoints[1].name == "Café")
    }

    @Test
    func route() throws {
        let route = try #require(try TestHelpers.fixture("full-1.1").routes.first)
        #expect(route.name == "Planned route")
        #expect(route.number == 7)
        #expect(route.type == "Run")
        #expect(route.points.map(\.name) == ["R1", "R2"])
        #expect(route.points.first?.elevation == 10)
    }

    @Test
    func trackSegmentsAndExtensions() throws {
        let track = try #require(try TestHelpers.fixture("full-1.1").tracks.first)
        #expect(track.name == "Recorded track")
        #expect(track.number == 1)
        #expect(track.segments.count == 2)
        #expect(track.points.count == 3)

        let extensionNode = try #require(track.segments[0].points[0].extensions.first)
        #expect(extensionNode.name == "gpxtpx:TrackPointExtension")
        #expect(extensionNode.child(named: "hr")?.text == "142")
        #expect(extensionNode.child(named: "gpxtpx:cad")?.text == "80")
    }

    @Test
    func timeVariants() throws {
        let points = try #require(try TestHelpers.fixture("full-1.1").tracks.first).points
        #expect(points[1].time == (try TestHelpers.date("2026-05-01T06:31:05Z")))  // +02:00 offset
        #expect(points[2].time == (try TestHelpers.date("2026-05-01T06:40:00Z")))  // no zone means UTC
    }

    @Test
    func documentExtensionsAndRootAttributes() throws {
        let document = try TestHelpers.fixture("full-1.1")
        #expect(document.extensions.first?.name == "x:flag")
        #expect(document.extensions.first?.attributes["kind"] == "demo")
        #expect(document.rootAttributes["xmlns:gpxtpx"] == "http://www.garmin.com/xmlschemas/TrackPointExtension/v1")
        #expect(document.rootAttributes["version"] == nil)
    }
}
