import Foundation
import Testing

@testable import GPXSwift

@Suite("Errors")
struct ErrorTests {
    @Test
    func malformedXML() {
        #expect {
            try GPXDocument(xml: "<gpx><wpt></gpx>")
        } throws: { error in
            if case GPXError.malformedXML = error { return true }
            return false
        }
    }

    @Test
    func emptyInput() {
        #expect(throws: GPXError.self) { try GPXDocument(data: Data()) }
    }

    @Test
    func notGPX() {
        #expect(throws: GPXError.notGPX(rootElement: "kml")) {
            try GPXDocument(xml: "<kml/>")
        }
    }

    @Test
    func missingLongitude() {
        let xml = #"<gpx version="1.1" creator="t"><wpt lat="1"/></gpx>"#
        #expect(throws: GPXError.missingAttribute(element: "wpt", attribute: "lon")) {
            try GPXDocument(xml: xml)
        }
    }

    @Test
    func invalidLatitude() {
        let xml = #"<gpx version="1.1" creator="t"><wpt lat="north" lon="1"/></gpx>"#
        #expect(throws: GPXError.invalidValue(element: "wpt", attribute: "lat", value: "north")) {
            try GPXDocument(xml: xml)
        }
    }

    @Test
    func badOptionalValuesAreDropped() throws {
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

    @Test
    func externalEntitiesAreNotResolved() {
        let xml = """
            <?xml version="1.0"?>
            <!DOCTYPE gpx [<!ENTITY secret SYSTEM "file:///etc/hosts">]>
            <gpx version="1.1" creator="&secret;"/>
            """
        let creator = (try? GPXDocument(xml: xml))?.creator ?? ""
        #expect(!creator.contains("localhost"))
    }
}
