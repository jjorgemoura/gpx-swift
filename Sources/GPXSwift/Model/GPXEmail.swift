/// An email address split into its two halves, as GPX 1.1 stores it.
public struct GPXEmail: Sendable, Hashable, Codable {
    /// The part of the address before the `@`.
    public var id: String

    /// The part of the address after the `@`.
    public var domain: String

    /// The full address, `id@domain`.
    public var address: String { "\(id)@\(domain)" }

    /// Creates an email address from its two halves.
    public init(id: String, domain: String) {
        self.id = id
        self.domain = domain
    }
}
