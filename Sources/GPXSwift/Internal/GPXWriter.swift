import Foundation

/// Serializes a ``GPXDocument`` as GPX 1.1, with elements in schema order.
struct GPXWriter {
    private static let namespace = "http://www.topografix.com/GPX/1/1"

    private var output = #"<?xml version="1.0" encoding="UTF-8"?>"# + "\n"
    private var depth = 0

    static func write(_ document: GPXDocument) -> String {
        var writer = GPXWriter()
        writer.write(document)
        return writer.output
    }

    // MARK: Document

    private mutating func write(_ document: GPXDocument) {
        var attributes = [("version", "1.1"), ("creator", document.creator), ("xmlns", Self.namespace)]
        for (name, value) in document.rootAttributes.sorted(by: { $0.key < $1.key }) {
            // The namespace is always GPX 1.1, so drop declarations that describe another version.
            if name == "xmlns" || (name.hasSuffix("schemaLocation") && document.version != "1.1") { continue }
            attributes.append((name, value))
        }

        open("gpx", attributes)
        if let metadata = document.metadata { write(metadata) }
        for waypoint in document.waypoints { write(waypoint, as: "wpt") }
        for route in document.routes { write(route) }
        for track in document.tracks { write(track) }
        write(document.extensions)
        close("gpx")
    }

    private mutating func write(_ metadata: GPXMetadata) {
        open("metadata")
        text("name", metadata.name)
        text("desc", metadata.description)
        if let author = metadata.author { write(author) }
        if let copyright = metadata.copyright { write(copyright) }
        metadata.links.forEach { write($0) }
        text("time", metadata.time.map(GPXDateCoding.format))
        text("keywords", metadata.keywords)
        if let bounds = metadata.bounds {
            leaf(
                "bounds",
                [
                    ("minlat", GPXDateCoding.decimal(bounds.minLatitude)),
                    ("minlon", GPXDateCoding.decimal(bounds.minLongitude)),
                    ("maxlat", GPXDateCoding.decimal(bounds.maxLatitude)),
                    ("maxlon", GPXDateCoding.decimal(bounds.maxLongitude)),
                ])
        }
        write(metadata.extensions)
        close("metadata")
    }

    private mutating func write(_ person: GPXPerson) {
        open("author")
        text("name", person.name)
        if let email = person.email { leaf("email", [("id", email.id), ("domain", email.domain)]) }
        if let link = person.link { write(link) }
        close("author")
    }

    private mutating func write(_ copyright: GPXCopyright) {
        open("copyright", [("author", copyright.author)])
        text("year", copyright.year.map(String.init))
        text("license", copyright.license)
        close("copyright")
    }

    private mutating func write(_ link: GPXLink) {
        open("link", [("href", link.href)])
        text("text", link.text)
        text("type", link.type)
        close("link")
    }

    // MARK: Points, routes, tracks

    private mutating func write(_ point: GPXWaypoint, as tag: String) {
        open(
            tag,
            [
                ("lat", GPXDateCoding.decimal(point.latitude)),
                ("lon", GPXDateCoding.decimal(point.longitude)),
            ])
        text("ele", point.elevation.map(GPXDateCoding.decimal))
        text("time", point.time.map(GPXDateCoding.format))
        text("magvar", point.magneticVariation.map(GPXDateCoding.decimal))
        text("geoidheight", point.geoidHeight.map(GPXDateCoding.decimal))
        text("name", point.name)
        text("cmt", point.comment)
        text("desc", point.description)
        text("src", point.source)
        point.links.forEach { write($0) }
        text("sym", point.symbol)
        text("type", point.type)
        text("fix", point.fix?.rawValue)
        text("sat", point.satellites.map(String.init))
        text("hdop", point.horizontalDilution.map(GPXDateCoding.decimal))
        text("vdop", point.verticalDilution.map(GPXDateCoding.decimal))
        text("pdop", point.positionDilution.map(GPXDateCoding.decimal))
        text("ageofdgpsdata", point.ageOfDGPSData.map(GPXDateCoding.decimal))
        text("dgpsid", point.dgpsStationID.map(String.init))
        write(point.extensions)
        close(tag)
    }

    private mutating func write(_ route: GPXRoute) {
        open("rte")
        text("name", route.name)
        text("cmt", route.comment)
        text("desc", route.description)
        text("src", route.source)
        route.links.forEach { write($0) }
        text("number", route.number.map(String.init))
        text("type", route.type)
        write(route.extensions)
        for point in route.points { write(point, as: "rtept") }
        close("rte")
    }

    private mutating func write(_ track: GPXTrack) {
        open("trk")
        text("name", track.name)
        text("cmt", track.comment)
        text("desc", track.description)
        text("src", track.source)
        track.links.forEach { write($0) }
        text("number", track.number.map(String.init))
        text("type", track.type)
        write(track.extensions)
        for segment in track.segments {
            open("trkseg")
            for point in segment.points { write(point, as: "trkpt") }
            write(segment.extensions)
            close("trkseg")
        }
        close("trk")
    }

    // MARK: Extensions

    private mutating func write(_ extensions: [GPXExtension]) {
        guard !extensions.isEmpty else { return }
        open("extensions")
        extensions.forEach { writeNode($0) }
        close("extensions")
    }

    private mutating func writeNode(_ node: GPXExtension) {
        let attributes = node.attributes.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
        if node.children.isEmpty {
            if let value = node.text {
                line("<\(node.name)\(render(attributes))>\(escape(value))</\(node.name)>")
            } else {
                line("<\(node.name)\(render(attributes))/>")
            }
        } else {
            open(node.name, attributes)
            node.children.forEach { writeNode($0) }
            close(node.name)
        }
    }

    // MARK: Output primitives

    private mutating func open(_ name: String, _ attributes: [(String, String)] = []) {
        line("<\(name)\(render(attributes))>")
        depth += 1
    }

    private mutating func close(_ name: String) {
        depth -= 1
        line("</\(name)>")
    }

    private mutating func leaf(_ name: String, _ attributes: [(String, String)]) {
        line("<\(name)\(render(attributes))/>")
    }

    private mutating func text(_ name: String, _ value: String?) {
        guard let value else { return }
        line("<\(name)>\(escape(value))</\(name)>")
    }

    private mutating func line(_ content: String) {
        output += String(repeating: "  ", count: depth) + content + "\n"
    }

    private func render(_ attributes: [(String, String)]) -> String {
        attributes.map { " \($0.0)=\"\(escape($0.1))\"" }.joined()
    }

    private func escape(_ value: String) -> String {
        var result = ""
        for character in value {
            switch character {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"": result += "&quot;"
            case "'": result += "&apos;"
            default: result.append(character)
            }
        }
        return result
    }
}
