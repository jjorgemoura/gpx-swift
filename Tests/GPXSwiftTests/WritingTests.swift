import Foundation
import Testing

@testable import GPXSwift

@Suite("Writing")
struct WritingTests {
    @Test(arguments: ["minimal", "full-1.1", "legacy-1.0"])
    func roundTrip(name: String) throws {
        let original = try TestHelpers.fixture(name)
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

    @Test
    func escapesSpecialCharacters() throws {
        let document = GPXDocument(
            creator: #"A & B "quoted" <tag>"#,
            waypoints: [GPXWaypoint(latitude: 1, longitude: 2, name: "Fish & Chips <3 'yum'")]
        )
        let reread = try GPXDocument(xml: document.xmlString())
        #expect(reread == document)
    }

    @Test
    func smallNumbersAreNotWrittenInScientificNotation() {
        #expect(GPXDateCoding.decimal(0.00001) == "0.00001")
        #expect(GPXDateCoding.decimal(-0.000000123) == "-0.000000123")
        #expect(GPXDateCoding.decimal(38.7223) == "38.7223")
        #expect(GPXDateCoding.decimal(1e21).contains("e") == false)
    }

    @Test
    func datesKeepMilliseconds() {
        let value = Date(timeIntervalSince1970: 1_700_000_000.25)
        #expect(GPXDateCoding.format(value) == "2023-11-14T22:13:20.250Z")
        #expect(GPXDateCoding.parse(GPXDateCoding.format(value)) == value)
        #expect(GPXDateCoding.format(Date(timeIntervalSince1970: 1_700_000_000)) == "2023-11-14T22:13:20Z")
    }

    @Test
    func buildsADocumentFromScratch() throws {
        let document = GPXDocument(
            creator: "tests",
            metadata: GPXMetadata(name: "Built"),
            tracks: [
                GPXTrack(
                    name: "T",
                    segments: [
                        GPXTrackSegment(points: [GPXWaypoint(latitude: 0.00001, longitude: -0.5, elevation: 3)])
                    ]
                )
            ]
        )
        let reread = try GPXDocument(data: document.xmlData())
        #expect(reread == document)
        #expect(reread.trackPoints.count == 1)
    }

    @Test
    func writtenFileCanBeReadBack() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).gpx")
        defer { try? FileManager.default.removeItem(at: url) }
        let document = try TestHelpers.fixture("full-1.1")
        try document.write(to: url)
        #expect(try GPXDocument(contentsOf: url).tracks == document.tracks)
    }

    @Test
    func codableRoundTrip() throws {
        let document = try TestHelpers.fixture("full-1.1")
        let data = try JSONEncoder().encode(document)
        #expect(try JSONDecoder().decode(GPXDocument.self, from: data) == document)
    }
}
