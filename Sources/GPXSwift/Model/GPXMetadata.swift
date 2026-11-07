import Foundation

/// File-level information about a GPX document.
public struct GPXMetadata: Sendable, Hashable, Codable {
    /// The name of the file.
    public var name: String?

    /// A description of the contents of the file.
    public var description: String?

    /// The person or organization who created the file.
    public var author: GPXPerson?

    /// Copyright and license information.
    public var copyright: GPXCopyright?

    /// URLs associated with the file.
    public var links: [GPXLink]

    /// The creation date of the file.
    public var time: Date?

    /// Keywords associated with the file, such as a comma-separated list.
    public var keywords: String?

    /// The minimum and maximum coordinates covered by the file.
    public var bounds: GPXBounds?

    /// Vendor extensions.
    public var extensions: [GPXExtension]

    /// Creates metadata.
    public init(
        name: String? = nil,
        description: String? = nil,
        author: GPXPerson? = nil,
        copyright: GPXCopyright? = nil,
        links: [GPXLink] = [],
        time: Date? = nil,
        keywords: String? = nil,
        bounds: GPXBounds? = nil,
        extensions: [GPXExtension] = []
    ) {
        self.name = name
        self.description = description
        self.author = author
        self.copyright = copyright
        self.links = links
        self.time = time
        self.keywords = keywords
        self.bounds = bounds
        self.extensions = extensions
    }
}

/// A person or organization.
public struct GPXPerson: Sendable, Hashable, Codable {
    /// The person's name.
    public var name: String?

    /// The person's email address.
    public var email: GPXEmail?

    /// A link to a web page about the person.
    public var link: GPXLink?

    /// Creates a person.
    public init(name: String? = nil, email: GPXEmail? = nil, link: GPXLink? = nil) {
        self.name = name
        self.email = email
        self.link = link
    }
}

/// An email address split into its two halves, as GPX 1.1 stores it.
public struct GPXEmail: Sendable, Hashable, Codable {
    /// The part of the address before the `@`.
    public var id: String

    /// The part of the address after the `@`.
    public var domain: String

    /// Creates an email address from its two halves.
    public init(id: String, domain: String) {
        self.id = id
        self.domain = domain
    }

    /// The full address, `id@domain`.
    public var address: String { "\(id)@\(domain)" }
}

/// Copyright and license information for a file.
public struct GPXCopyright: Sendable, Hashable, Codable {
    /// The copyright holder.
    public var author: String

    /// The year of copyright.
    public var year: Int?

    /// A URL pointing to the license text.
    public var license: String?

    /// Creates a copyright statement.
    public init(author: String, year: Int? = nil, license: String? = nil) {
        self.author = author
        self.year = year
        self.license = license
    }
}

/// A hyperlink to additional information.
public struct GPXLink: Sendable, Hashable, Codable {
    /// The URL of the link.
    public var href: String

    /// The text to display for the link.
    public var text: String?

    /// The MIME type of the linked content.
    public var type: String?

    /// Creates a link.
    public init(href: String, text: String? = nil, type: String? = nil) {
        self.href = href
        self.text = text
        self.type = type
    }
}

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
