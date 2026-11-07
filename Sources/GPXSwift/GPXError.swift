/// Errors thrown while reading a GPX file.
///
/// The reader is strict about structure and coordinates and lenient about everything else:
/// an unparseable optional value (a malformed `<time>`, say) is dropped rather than failing
/// the whole file.
public enum GPXError: Error, Sendable, Equatable {
    /// The data is not well-formed XML.
    case malformedXML(line: Int, column: Int, message: String)

    /// The root element is not `<gpx>`.
    case notGPX(rootElement: String)

    /// A required attribute, such as `lat` or `lon`, is missing.
    case missingAttribute(element: String, attribute: String)

    /// A required attribute is present but cannot be parsed.
    case invalidValue(element: String, attribute: String, value: String)
}

extension GPXError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .malformedXML(let line, let column, let message):
            "Malformed XML at line \(line), column \(column): \(message)"
        case .notGPX(let rootElement):
            "Root element is <\(rootElement)>, expected <gpx>"
        case .missingAttribute(let element, let attribute):
            "<\(element)> is missing the required attribute \"\(attribute)\""
        case .invalidValue(let element, let attribute, let value):
            "<\(element)> has an invalid \"\(attribute)\" value: \"\(value)\""
        }
    }
}
