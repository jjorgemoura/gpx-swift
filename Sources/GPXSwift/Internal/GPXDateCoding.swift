import Foundation

/// ISO 8601 / `xsd:dateTime` conversion.
enum GPXDateCoding {
    /// Parses a GPX time, with or without fractional seconds. A value without a time zone
    /// designator is taken as UTC.
    static func parse(_ text: String) -> Date? {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        for candidate in [text, text + "Z"] {
            if let date = try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(candidate) {
                return date
            }
            if let date = try? Date.ISO8601FormatStyle().parse(candidate) {
                return date
            }
        }
        return nil
    }

    /// Formats a date as UTC, with milliseconds only when the date has them.
    static func format(_ date: Date) -> String {
        let milliseconds = (date.timeIntervalSince1970 * 1000).rounded()
        let hasFraction = milliseconds.truncatingRemainder(dividingBy: 1000) != 0
        return Date.ISO8601FormatStyle(includingFractionalSeconds: hasFraction).format(date)
    }

    /// Formats a number as a plain decimal. Swift prints small and large values in scientific
    /// notation, which `xsd:decimal` (latitude, longitude, elevation) does not allow.
    static func decimal(_ value: Double) -> String {
        let text = "\(value)"
        guard text.contains("e") || text.contains("E") else { return text }
        var fixed = String(format: "%.15f", value)
        while fixed.hasSuffix("0") { fixed.removeLast() }
        if fixed.hasSuffix(".") { fixed.append("0") }
        return fixed
    }
}
