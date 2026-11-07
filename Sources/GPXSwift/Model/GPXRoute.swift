/// An ordered list of points describing a path to follow to a destination.
public struct GPXRoute: Sendable, Hashable, Codable {
    /// The name of the route.
    public var name: String?

    /// A GPS comment for the route.
    public var comment: String?

    /// A text description of the route.
    public var description: String?

    /// The source of the data.
    public var source: String?

    /// Links to additional information about the route.
    public var links: [GPXLink]

    /// The GPS route number.
    public var number: Int?

    /// The classification of the route.
    public var type: String?

    /// Vendor extensions.
    public var extensions: [GPXExtension]

    /// The points that make up the route, in order.
    public var points: [GPXWaypoint]

    /// Creates a route.
    public init(
        name: String? = nil,
        comment: String? = nil,
        description: String? = nil,
        source: String? = nil,
        links: [GPXLink] = [],
        number: Int? = nil,
        type: String? = nil,
        extensions: [GPXExtension] = [],
        points: [GPXWaypoint] = []
    ) {
        self.name = name
        self.comment = comment
        self.description = description
        self.source = source
        self.links = links
        self.number = number
        self.type = type
        self.extensions = extensions
        self.points = points
    }
}
