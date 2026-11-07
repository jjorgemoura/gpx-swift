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
