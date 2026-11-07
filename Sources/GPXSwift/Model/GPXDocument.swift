import Foundation

/// A GPX file: waypoints, routes and tracks plus the information describing them.
///
/// Read a file with ``init(data:)``, ``init(xml:)`` or ``init(contentsOf:)``, and write one
/// back with ``xmlString()`` or ``xmlData()``. GPX 1.1 and 1.0 files can be read; output is
/// always GPX 1.1.
public struct GPXDocument: Sendable, Hashable, Codable {
    /// The GPX version declared by the file that was read, `1.1` for new documents.
    public var version: String

    /// The name or URL of the software that created the file.
    public var creator: String

    /// Information about the file.
    public var metadata: GPXMetadata?

    /// The standalone waypoints.
    public var waypoints: [GPXWaypoint]

    /// The routes.
    public var routes: [GPXRoute]

    /// The tracks.
    public var tracks: [GPXTrack]

    /// Vendor extensions at the document level.
    public var extensions: [GPXExtension]

    /// Extra attributes on the `<gpx>` element, such as `xmlns:gpxtpx` declarations, kept so
    /// that extension prefixes stay valid when the document is written.
    public var rootAttributes: [String: String]

    /// Every point of every track, in order.
    public var trackPoints: [GPXWaypoint] {
        tracks.flatMap(\.points)
    }

    /// Creates a document.
    public init(
        version: String = "1.1",
        creator: String = "",
        metadata: GPXMetadata? = nil,
        waypoints: [GPXWaypoint] = [],
        routes: [GPXRoute] = [],
        tracks: [GPXTrack] = [],
        extensions: [GPXExtension] = [],
        rootAttributes: [String: String] = [:]
    ) {
        self.version = version
        self.creator = creator
        self.metadata = metadata
        self.waypoints = waypoints
        self.routes = routes
        self.tracks = tracks
        self.extensions = extensions
        self.rootAttributes = rootAttributes
    }

    /// Reads a document from GPX data.
    ///
    /// - Throws: ``GPXError`` when the data is not well-formed XML, is not a GPX file, or has a
    ///   point without a valid `lat` and `lon`.
    public init(data: Data) throws {
        let root = try RawElement.parse(data)
        self = try GPXReader.document(from: root)
    }

    /// Reads a document from a GPX string.
    ///
    /// - Throws: ``GPXError``, as for ``init(data:)``.
    public init(xml: String) throws {
        try self.init(data: Data(xml.utf8))
    }

    /// Reads a document from a file.
    ///
    /// - Throws: ``GPXError``, as for ``init(data:)``, or a file-reading error.
    public init(contentsOf url: URL) throws {
        try self.init(data: Data(contentsOf: url))
    }

    /// The document as GPX 1.1 XML.
    public func xmlString() -> String {
        GPXWriter.write(self)
    }

    /// The document as UTF-8 encoded GPX 1.1 XML.
    public func xmlData() -> Data {
        Data(xmlString().utf8)
    }

    /// Writes the document to a file as GPX 1.1 XML.
    public func write(to url: URL) throws {
        try xmlData().write(to: url, options: .atomic)
    }
}
