import Testing

@testable import GPXSwift

@Suite("Reading GPX 1.0")
struct LegacyTests {
    @Test
    func metadataIsLiftedFromTheRoot() throws {
        let document = try TestHelpers.fixture("legacy-1.0")
        #expect(document.version == "1.0")
        let metadata = try #require(document.metadata)
        #expect(metadata.name == "Legacy file")
        #expect(metadata.author == GPXPerson(name: "Bob", email: GPXEmail(id: "bob", domain: "example.org")))
        #expect(metadata.links == [GPXLink(href: "https://example.org/bob", text: "Bob's site")])
        #expect(metadata.bounds == GPXBounds(minLatitude: 1, minLongitude: 2, maxLatitude: 3, maxLongitude: 4))
        #expect(metadata.time == (try TestHelpers.date("2005-01-01T12:00:00Z")))
    }

    @Test
    func waypointKeepsSpeedCourseAndUrl() throws {
        let waypoint = try #require(try TestHelpers.fixture("legacy-1.0").waypoints.first)
        #expect(waypoint.speed == 3.5)
        #expect(waypoint.course == 90)
        #expect(waypoint.links == [GPXLink(href: "https://example.org/w1", text: "W1 page")])
    }

    @Test
    func writesAsGPX11() throws {
        let xml = try TestHelpers.fixture("legacy-1.0").xmlString()
        #expect(xml.contains(#"version="1.1""#))
        #expect(xml.contains("http://www.topografix.com/GPX/1/1"))
        let reread = try GPXDocument(xml: xml)
        #expect(reread.metadata?.name == "Legacy file")
        #expect(reread.tracks.first?.number == 3)
    }
}
