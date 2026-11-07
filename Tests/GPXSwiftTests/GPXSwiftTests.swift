import Foundation
import Testing

@testable import GPXSwift

private func fixture(_ name: String) throws -> GPXDocument {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "gpx", subdirectory: "Fixtures"))
    return try GPXDocument(contentsOf: url)
}

private func date(_ iso: String) throws -> Date {
    try #require(GPXDateCoding.parse(iso))
}

@Suite("Reading GPX 1.1")
struct ReadingTests {
    @Test func minimalDocument() throws {
        let document = try fixture("minimal")
        #expect(document.creator == "min")
        #expect(document.version == "1.1")
        #expect(document.metadata == nil)
        #expect(document.waypoints.isEmpty && document.routes.isEmpty && document.tracks.isEmpty)
    }

    @Test func metadata() throws {
        let metadata = try #require(try fixture("full-1.1").metadata)
        #expect(metadata.name == "Morning & evening loop")
        #expect(metadata.description == "Every element of the GPX 1.1 schema")
        #expect(metadata.author?.name == "Jane Walker")
        #expect(metadata.author?.email?.address == "jane@example.com")
        #expect(metadata.author?.link == GPXLink(href: "https://example.com/jane", text: "Jane's page", type: "text/html"))
        #expect(metadata.copyright == GPXCopyright(author: "Jane Walker", year: 2026, license: "https://example.com/license"))
        #expect(metadata.links == [GPXLink(href: "https://example.com/loop", text: "The loop")])
        #expect(metadata.time == (try date("2026-05-01T06:30:00Z")))
        #expect(metadata.keywords == "run, loop, test")
        #expect(metadata.bounds == GPXBounds(minLatitude: 38.70, minLongitude: -9.20, maxLatitude: 38.80, maxLongitude: -9.10))
        #expect(metadata.extensions.first?.name == "meta:note")
        #expect(metadata.extensions.first?.text == "kept")
    }

    @Test func waypointWithEveryField() throws {
        let waypoint = try #require(try fixture("full-1.1").waypoints.first)
        #expect(waypoint.latitude == 38.7223)
        #expect(waypoint.longitude == -9.1393)
        #expect(waypoint.elevation == 12.5)
        #expect(waypoint.time == (try date("2026-05-01T06:31:00.250Z")))
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

    @Test func nonASCIIText() throws {
        let document = try fixture("full-1.1")
        #expect(document.waypoints[1].name == "Café")
    }

    @Test func route() throws {
        let route = try #require(try fixture("full-1.1").routes.first)
        #expect(route.name == "Planned route")
        #expect(route.number == 7)
        #expect(route.type == "Run")
        #expect(route.points.map(\.name) == ["R1", "R2"])
        #expect(route.points.first?.elevation == 10)
    }

    @Test func trackSegmentsAndExtensions() throws {
        let track = try #require(try fixture("full-1.1").tracks.first)
        #expect(track.name == "Recorded track")
        #expect(track.number == 1)
        #expect(track.segments.count == 2)
        #expect(track.points.count == 3)

        let extensionNode = try #require(track.segments[0].points[0].extensions.first)
        #expect(extensionNode.name == "gpxtpx:TrackPointExtension")
        #expect(extensionNode.child(named: "hr")?.text == "142")
        #expect(extensionNode.child(named: "gpxtpx:cad")?.text == "80")
    }

    @Test func timeVariants() throws {
        let points = try #require(try fixture("full-1.1").tracks.first).points
        #expect(points[1].time == (try date("2026-05-01T06:31:05Z")))  // +02:00 offset
        #expect(points[2].time == (try date("2026-05-01T06:40:00Z")))  // no zone means UTC
    }

    @Test func documentExtensionsAndRootAttributes() throws {
        let document = try fixture("full-1.1")
        #expect(document.extensions.first?.name == "x:flag")
        #expect(document.extensions.first?.attributes["kind"] == "demo")
        #expect(document.rootAttributes["xmlns:gpxtpx"] == "http://www.garmin.com/xmlschemas/TrackPointExtension/v1")
        #expect(document.rootAttributes["version"] == nil)
    }
}

@Suite("Reading GPX 1.0")
struct LegacyTests {
    @Test func metadataIsLiftedFromTheRoot() throws {
        let document = try fixture("legacy-1.0")
        #expect(document.version == "1.0")
        let metadata = try #require(document.metadata)
        #expect(metadata.name == "Legacy file")
        #expect(metadata.author == GPXPerson(name: "Bob", email: GPXEmail(id: "bob", domain: "example.org")))
        #expect(metadata.links == [GPXLink(href: "https://example.org/bob", text: "Bob's site")])
        #expect(metadata.bounds == GPXBounds(minLatitude: 1, minLongitude: 2, maxLatitude: 3, maxLongitude: 4))
        #expect(metadata.time == (try date("2005-01-01T12:00:00Z")))
    }

    @Test func waypointKeepsSpeedCourseAndUrl() throws {
        let waypoint = try #require(try fixture("legacy-1.0").waypoints.first)
        #expect(waypoint.speed == 3.5)
        #expect(waypoint.course == 90)
        #expect(waypoint.links == [GPXLink(href: "https://example.org/w1", text: "W1 page")])
    }

    @Test func writesAsGPX11() throws {
        let xml = try fixture("legacy-1.0").xmlString()
        #expect(xml.contains(#"version="1.1""#))
        #expect(xml.contains("http://www.topografix.com/GPX/1/1"))
        let reread = try GPXDocument(xml: xml)
        #expect(reread.metadata?.name == "Legacy file")
        #expect(reread.tracks.first?.number == 3)
    }
}

@Suite("Errors")
struct ErrorTests {
    @Test func malformedXML() {
        #expect {
            try GPXDocument(xml: "<gpx><wpt></gpx>")
        } throws: { error in
            if case GPXError.malformedXML = error { return true }
            return false
        }
    }

    @Test func emptyInput() {
        #expect(throws: GPXError.self) { try GPXDocument(data: Data()) }
    }

    @Test func notGPX() {
        #expect(throws: GPXError.notGPX(rootElement: "kml")) {
            try GPXDocument(xml: "<kml/>")
        }
    }

    @Test func missingLongitude() {
        let xml = #"<gpx version="1.1" creator="t"><wpt lat="1"/></gpx>"#
        #expect(throws: GPXError.missingAttribute(element: "wpt", attribute: "lon")) {
            try GPXDocument(xml: xml)
        }
    }

    @Test func invalidLatitude() {
        let xml = #"<gpx version="1.1" creator="t"><wpt lat="north" lon="1"/></gpx>"#
        #expect(throws: GPXError.invalidValue(element: "wpt", attribute: "lat", value: "north")) {
            try GPXDocument(xml: xml)
        }
    }

    @Test func badOptionalValuesAreDropped() throws {
        let xml = """
            <gpx version="1.1" creator="t"><wpt lat="1" lon="2">
              <ele>high</ele><time>yesterday</time><fix>maybe</fix><sat>many</sat>
            </wpt></gpx>
            """
        let waypoint = try #require(try GPXDocument(xml: xml).waypoints.first)
        #expect(waypoint.elevation == nil)
        #expect(waypoint.time == nil)
        #expect(waypoint.fix == nil)
        #expect(waypoint.satellites == nil)
    }

    @Test func externalEntitiesAreNotResolved() throws {
        let xml = """
            <?xml version="1.0"?>
            <!DOCTYPE gpx [<!ENTITY secret SYSTEM "file:///etc/hosts">]>
            <gpx version="1.1" creator="&secret;"/>
            """
        let creator = (try? GPXDocument(xml: xml))?.creator ?? ""
        #expect(!creator.contains("localhost"))
    }
}

@Suite("Writing")
struct WritingTests {
    @Test(arguments: ["minimal", "full-1.1", "legacy-1.0"])
    func roundTrip(name: String) throws {
        let original = try fixture(name)
        let reread = try GPXDocument(xml: original.xmlString())
        var expected = original
        expected.version = "1.1"
        if name == "legacy-1.0" {
            // GPX 1.0 only fields have no home in GPX 1.1 and are not written.
            expected.waypoints = expected.waypoints.map {
                var point = $0
                point.speed = nil
                point.course = nil
                return point
            }
            expected.rootAttributes = [:]
        }
        #expect(reread == expected)
    }

    @Test func escapesSpecialCharacters() throws {
        let document = GPXDocument(
            creator: #"A & B "quoted" <tag>"#,
            waypoints: [GPXWaypoint(latitude: 1, longitude: 2, name: "Fish & Chips <3 'yum'")]
        )
        let reread = try GPXDocument(xml: document.xmlString())
        #expect(reread == document)
    }

    @Test func smallNumbersAreNotWrittenInScientificNotation() {
        #expect(GPXDateCoding.decimal(0.00001) == "0.00001")
        #expect(GPXDateCoding.decimal(-0.000000123) == "-0.000000123")
        #expect(GPXDateCoding.decimal(38.7223) == "38.7223")
        #expect(GPXDateCoding.decimal(1e21).contains("e") == false)
    }

    @Test func datesKeepMilliseconds() throws {
        let value = Date(timeIntervalSince1970: 1_700_000_000.25)
        #expect(GPXDateCoding.format(value) == "2023-11-14T22:13:20.250Z")
        #expect(GPXDateCoding.parse(GPXDateCoding.format(value)) == value)
        #expect(GPXDateCoding.format(Date(timeIntervalSince1970: 1_700_000_000)) == "2023-11-14T22:13:20Z")
    }

    @Test func buildsADocumentFromScratch() throws {
        let document = GPXDocument(
            creator: "tests",
            metadata: GPXMetadata(name: "Built"),
            tracks: [
                GPXTrack(
                    name: "T",
                    segments: [
                        GPXTrackSegment(points: [GPXWaypoint(latitude: 0.00001, longitude: -0.5, elevation: 3)])
                    ])
            ]
        )
        let reread = try GPXDocument(data: document.xmlData())
        #expect(reread == document)
        #expect(reread.trackPoints.count == 1)
    }

    @Test func writtenFileCanBeReadBack() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).gpx")
        defer { try? FileManager.default.removeItem(at: url) }
        let document = try fixture("full-1.1")
        try document.write(to: url)
        #expect(try GPXDocument(contentsOf: url).tracks == document.tracks)
    }

    @Test func codableRoundTrip() throws {
        let document = try fixture("full-1.1")
        let data = try JSONEncoder().encode(document)
        #expect(try JSONDecoder().decode(GPXDocument.self, from: data) == document)
    }
}
