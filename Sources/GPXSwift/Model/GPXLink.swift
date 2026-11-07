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
