/// A generic XML element found inside an `<extensions>` block.
///
/// Extensions are kept as a lossless tree, so vendor data such as Garmin's
/// `gpxtpx:TrackPointExtension` survives a read and write round trip. Names keep their
/// namespace prefix exactly as written in the file.
public struct GPXExtension: Sendable, Hashable, Codable {
    /// The qualified element name, for example `gpxtpx:hr`.
    public var name: String

    /// The element's attributes.
    public var attributes: [String: String]

    /// The element's text, trimmed, or `nil` when it has none.
    public var text: String?

    /// The element's child elements.
    public var children: [Self]

    /// The element name without its namespace prefix.
    public var localName: String {
        name.split(separator: ":", omittingEmptySubsequences: false).last.map(String.init) ?? name
    }

    /// Creates an extension element.
    public init(
        name: String,
        attributes: [String: String] = [:],
        text: String? = nil,
        children: [Self] = []
    ) {
        self.name = name
        self.attributes = attributes
        self.text = text
        self.children = children
    }

    /// The first child whose qualified name or local name equals `name`.
    public func child(named name: String) -> Self? {
        children.first { $0.name == name || $0.localName == name }
    }
}
