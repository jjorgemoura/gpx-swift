/// Two latitude/longitude pairs describing a rectangular extent, in decimal degrees.
public struct GPXBounds: Sendable, Hashable, Codable {
    /// The southern edge.
    public var minLatitude: Double

    /// The western edge.
    public var minLongitude: Double

    /// The northern edge.
    public var maxLatitude: Double

    /// The eastern edge.
    public var maxLongitude: Double

    /// Creates bounds.
    public init(
        minLatitude: Double,
        minLongitude: Double,
        maxLatitude: Double,
        maxLongitude: Double
    ) {
        self.minLatitude = minLatitude
        self.minLongitude = minLongitude
        self.maxLatitude = maxLatitude
        self.maxLongitude = maxLongitude
    }
}
