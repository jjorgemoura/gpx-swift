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
