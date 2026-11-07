import Foundation

/// A point with a position, used for waypoints, route points and track points.
public struct GPXWaypoint: Sendable, Hashable, Codable {
    /// Latitude in decimal degrees, WGS84.
    public var latitude: Double

    /// Longitude in decimal degrees, WGS84.
    public var longitude: Double

    /// Elevation in meters.
    public var elevation: Double?

    /// The time the position was recorded.
    public var time: Date?

    /// Magnetic variation in degrees.
    public var magneticVariation: Double?

    /// Height of the geoid above the WGS84 ellipsoid, in meters.
    public var geoidHeight: Double?

    /// The name of the point.
    public var name: String?

    /// A GPS comment for the point.
    public var comment: String?

    /// A text description of the point.
    public var description: String?

    /// The source of the data, such as a device or a map.
    public var source: String?

    /// Links to additional information about the point.
    public var links: [GPXLink]

    /// The GPS symbol name, used to pick an icon.
    public var symbol: String?

    /// The classification of the point.
    public var type: String?

    /// The type of GPS fix.
    public var fix: GPXFix?

    /// The number of satellites used to calculate the position.
    public var satellites: Int?

    /// Horizontal dilution of precision.
    public var horizontalDilution: Double?

    /// Vertical dilution of precision.
    public var verticalDilution: Double?

    /// Position dilution of precision.
    public var positionDilution: Double?

    /// Seconds since the last DGPS update.
    public var ageOfDGPSData: Double?

    /// The ID of the DGPS station used, 0 through 1023.
    public var dgpsStationID: Int?

    /// Ground speed in meters per second. Only present in GPX 1.0 files; it is not written.
    public var speed: Double?

    /// Heading in degrees. Only present in GPX 1.0 files; it is not written.
    public var course: Double?

    /// Vendor extensions, such as heart rate or cadence.
    public var extensions: [GPXExtension]

    /// Creates a point.
    public init(
        latitude: Double,
        longitude: Double,
        elevation: Double? = nil,
        time: Date? = nil,
        magneticVariation: Double? = nil,
        geoidHeight: Double? = nil,
        name: String? = nil,
        comment: String? = nil,
        description: String? = nil,
        source: String? = nil,
        links: [GPXLink] = [],
        symbol: String? = nil,
        type: String? = nil,
        fix: GPXFix? = nil,
        satellites: Int? = nil,
        horizontalDilution: Double? = nil,
        verticalDilution: Double? = nil,
        positionDilution: Double? = nil,
        ageOfDGPSData: Double? = nil,
        dgpsStationID: Int? = nil,
        speed: Double? = nil,
        course: Double? = nil,
        extensions: [GPXExtension] = []
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.time = time
        self.magneticVariation = magneticVariation
        self.geoidHeight = geoidHeight
        self.name = name
        self.comment = comment
        self.description = description
        self.source = source
        self.links = links
        self.symbol = symbol
        self.type = type
        self.fix = fix
        self.satellites = satellites
        self.horizontalDilution = horizontalDilution
        self.verticalDilution = verticalDilution
        self.positionDilution = positionDilution
        self.ageOfDGPSData = ageOfDGPSData
        self.dgpsStationID = dgpsStationID
        self.speed = speed
        self.course = course
        self.extensions = extensions
    }
}

/// The type of GPS fix used to calculate a position.
public enum GPXFix: String, Sendable, Hashable, Codable {
    /// No fix.
    case none

    /// A two-dimensional fix.
    case twoD = "2d"

    /// A three-dimensional fix.
    case threeD = "3d"

    /// A differential GPS fix.
    case dgps

    /// A military-signal fix.
    case pps
}
