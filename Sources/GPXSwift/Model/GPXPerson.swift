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
