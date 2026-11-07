/// An ordered list of track segments describing a path that was travelled.
public struct GPXTrack: Sendable, Hashable, Codable {
    /// The name of the track.
    public var name: String?

    /// A GPS comment for the track.
    public var comment: String?

    /// A text description of the track.
    public var description: String?

    /// The source of the data.
    public var source: String?

    /// Links to additional information about the track.
    public var links: [GPXLink]

    /// The GPS track number.
    public var number: Int?

    /// The classification of the track.
    public var type: String?

    /// Vendor extensions.
    public var extensions: [GPXExtension]

    /// The track's segments, in order.
    public var segments: [GPXTrackSegment]

    /// Creates a track.
    public init(
        name: String? = nil,
        comment: String? = nil,
        description: String? = nil,
        source: String? = nil,
        links: [GPXLink] = [],
        number: Int? = nil,
        type: String? = nil,
        extensions: [GPXExtension] = [],
        segments: [GPXTrackSegment] = []
    ) {
        self.name = name
        self.comment = comment
        self.description = description
        self.source = source
        self.links = links
        self.number = number
        self.type = type
        self.extensions = extensions
        self.segments = segments
    }

    /// Every point of every segment, in order.
    public var points: [GPXWaypoint] {
        segments.flatMap(\.points)
    }
}

/// A continuous run of track points.
///
/// A new segment starts where the receiver lost its signal or was switched off.
public struct GPXTrackSegment: Sendable, Hashable, Codable {
    /// The points of the segment, in order.
    public var points: [GPXWaypoint]

    /// Vendor extensions.
    public var extensions: [GPXExtension]

    /// Creates a segment.
    public init(points: [GPXWaypoint] = [], extensions: [GPXExtension] = []) {
        self.points = points
        self.extensions = extensions
    }
}
