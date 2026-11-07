import Foundation

/// Maps a ``RawElement`` tree onto the public model. Reads GPX 1.1 and GPX 1.0.
enum GPXReader {
    static func document(from root: RawElement) throws -> GPXDocument {
        guard root.localName == "gpx" else {
            throw GPXError.notGPX(rootElement: root.name)
        }
        let version = root.attributes["version"] ?? "1.1"

        var rootAttributes = root.attributes
        rootAttributes["version"] = nil
        rootAttributes["creator"] = nil
        rootAttributes["xmlns"] = nil  // the writer always declares the GPX 1.1 namespace

        return GPXDocument(
            version: version,
            creator: root.attributes["creator"] ?? "",
            metadata: version == "1.0" ? legacyMetadata(root) : root.child("metadata").map(metadata),
            waypoints: try root.children("wpt").map(point),
            routes: try root.children("rte").map(route),
            tracks: try root.children("trk").map(track),
            extensions: extensions(of: root),
            rootAttributes: rootAttributes
        )
    }

    // MARK: Points, routes, tracks

    private static func point(_ element: RawElement) throws -> GPXWaypoint {
        GPXWaypoint(
            latitude: try coordinate("lat", in: element),
            longitude: try coordinate("lon", in: element),
            elevation: element.double("ele"),
            time: element.date("time"),
            magneticVariation: element.double("magvar"),
            geoidHeight: element.double("geoidheight"),
            name: element.string("name"),
            comment: element.string("cmt"),
            description: element.string("desc"),
            source: element.string("src"),
            links: links(of: element),
            symbol: element.string("sym"),
            type: element.string("type"),
            fix: element.string("fix").flatMap(GPXFix.init(rawValue:)),
            satellites: element.int("sat"),
            horizontalDilution: element.double("hdop"),
            verticalDilution: element.double("vdop"),
            positionDilution: element.double("pdop"),
            ageOfDGPSData: element.double("ageofdgpsdata"),
            dgpsStationID: element.int("dgpsid"),
            speed: element.double("speed"),
            course: element.double("course"),
            extensions: extensions(of: element)
        )
    }

    private static func route(_ element: RawElement) throws -> GPXRoute {
        GPXRoute(
            name: element.string("name"),
            comment: element.string("cmt"),
            description: element.string("desc"),
            source: element.string("src"),
            links: links(of: element),
            number: element.int("number"),
            type: element.string("type"),
            extensions: extensions(of: element),
            points: try element.children("rtept").map(point)
        )
    }

    private static func track(_ element: RawElement) throws -> GPXTrack {
        GPXTrack(
            name: element.string("name"),
            comment: element.string("cmt"),
            description: element.string("desc"),
            source: element.string("src"),
            links: links(of: element),
            number: element.int("number"),
            type: element.string("type"),
            extensions: extensions(of: element),
            segments: try element.children("trkseg").map { segment in
                GPXTrackSegment(
                    points: try segment.children("trkpt").map(point),
                    extensions: extensions(of: segment)
                )
            }
        )
    }

    private static func coordinate(_ attribute: String, in element: RawElement) throws -> Double {
        guard let text = element.attributes[attribute] else {
            throw GPXError.missingAttribute(element: element.name, attribute: attribute)
        }
        guard let value = Double(text.trimmingCharacters(in: .whitespaces)), value.isFinite else {
            throw GPXError.invalidValue(element: element.name, attribute: attribute, value: text)
        }
        return value
    }

    // MARK: Metadata

    private static func metadata(_ element: RawElement) -> GPXMetadata {
        GPXMetadata(
            name: element.string("name"),
            description: element.string("desc"),
            author: element.child("author").map(person),
            copyright: element.child("copyright").flatMap(copyright),
            links: links(of: element),
            time: element.date("time"),
            keywords: element.string("keywords"),
            bounds: element.child("bounds").flatMap(bounds),
            extensions: extensions(of: element)
        )
    }

    /// GPX 1.0 keeps the metadata directly under `<gpx>`, and the author as plain text.
    private static func legacyMetadata(_ root: RawElement) -> GPXMetadata? {
        let author = root.string("author")
        let email = root.string("email").flatMap(splitEmail)
        let metadata = GPXMetadata(
            name: root.string("name"),
            description: root.string("desc"),
            author: author == nil && email == nil ? nil : GPXPerson(name: author, email: email),
            links: links(of: root),
            time: root.date("time"),
            keywords: root.string("keywords"),
            bounds: root.child("bounds").flatMap(bounds)
        )
        return metadata == GPXMetadata() ? nil : metadata
    }

    private static func person(_ element: RawElement) -> GPXPerson {
        GPXPerson(
            name: element.string("name"),
            email: element.child("email").flatMap { email in
                guard let id = email.attributes["id"],
                    let domain = email.attributes["domain"]
                else {
                    return nil
                }
                return GPXEmail(id: id, domain: domain)
            },
            link: element.child("link").flatMap(link)
        )
    }

    private static func copyright(_ element: RawElement) -> GPXCopyright? {
        guard let author = element.attributes["author"] else { return nil }
        return GPXCopyright(
            author: author,
            year: element.int("year"),
            license: element.string("license")
        )
    }

    private static func bounds(_ element: RawElement) -> GPXBounds? {
        func value(_ name: String) -> Double? { element.attributes[name].flatMap { Double($0) } }
        guard
            let minLatitude = value("minlat"), let minLongitude = value("minlon"),
            let maxLatitude = value("maxlat"), let maxLongitude = value("maxlon")
        else { return nil }
        return GPXBounds(
            minLatitude: minLatitude,
            minLongitude: minLongitude,
            maxLatitude: maxLatitude,
            maxLongitude: maxLongitude
        )
    }

    private static func splitEmail(_ address: String) -> GPXEmail? {
        let parts = address.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        return GPXEmail(id: String(parts[0]), domain: String(parts[1]))
    }

    // MARK: Links and extensions

    /// `<link>` elements, plus the GPX 1.0 `<url>` and `<urlname>` pair.
    private static func links(of element: RawElement) -> [GPXLink] {
        var result = element.children("link").compactMap(link)
        if let url = element.string("url") {
            result.append(GPXLink(href: url, text: element.string("urlname")))
        }
        return result
    }

    private static func link(_ element: RawElement) -> GPXLink? {
        guard let href = element.attributes["href"] else { return nil }
        return GPXLink(href: href, text: element.string("text"), type: element.string("type"))
    }

    private static func extensions(of element: RawElement) -> [GPXExtension] {
        element.children("extensions").flatMap { $0.children.map(extensionNode) }
    }

    private static func extensionNode(_ element: RawElement) -> GPXExtension {
        GPXExtension(
            name: element.name,
            attributes: element.attributes,
            text: element.text.isEmpty ? nil : element.text,
            children: element.children.map(extensionNode)
        )
    }
}
