import Foundation

#if canImport(FoundationXML)
    import FoundationXML
#endif

/// A minimal XML element tree built from `XMLParser`.
struct RawElement: Sendable, Equatable {
    var name: String
    var attributes: [String: String] = [:]
    var text = ""
    var children: [RawElement] = []

    /// The element name without its namespace prefix.
    var localName: String {
        name.split(separator: ":", omittingEmptySubsequences: false).last.map(String.init) ?? name
    }

    /// Parses `data` into an element tree and returns the root element.
    static func parse(_ data: Data) throws -> RawElement {
        let builder = TreeBuilder()
        let parser = XMLParser(data: data)
        parser.delegate = builder
        parser.shouldProcessNamespaces = false
        parser.shouldResolveExternalEntities = false  // no XXE
        guard parser.parse(), let root = builder.root else {
            throw GPXError.malformedXML(
                line: parser.lineNumber,
                column: parser.columnNumber,
                message: parser.parserError?.localizedDescription ?? "The document has no root element"
            )
        }
        return root
    }
}

extension RawElement {
    /// The first child with the given local name.
    func child(_ localName: String) -> RawElement? {
        children.first { $0.localName == localName }
    }

    /// All children with the given local name, in document order.
    func children(_ localName: String) -> [RawElement] {
        children.filter { $0.localName == localName }
    }

    /// The trimmed text of the named child, or `nil` when absent or empty.
    func string(_ localName: String) -> String? {
        guard let text = child(localName)?.text, !text.isEmpty else { return nil }
        return text
    }

    /// The named child's text as a `Double`, or `nil` when absent or unparseable.
    func double(_ localName: String) -> Double? {
        string(localName).flatMap { Double($0) }.flatMap { $0.isFinite ? $0 : nil }
    }

    /// The named child's text as an `Int`, or `nil` when absent or unparseable.
    func int(_ localName: String) -> Int? {
        string(localName).flatMap { Int($0) }
    }

    /// The named child's text as a date, or `nil` when absent or unparseable.
    func date(_ localName: String) -> Date? {
        string(localName).flatMap(GPXDateCoding.parse)
    }
}

/// Builds a ``RawElement`` tree iteratively, so deep documents cannot overflow the stack.
private final class TreeBuilder: NSObject, XMLParserDelegate {
    private var stack: [RawElement] = []
    private(set) var root: RawElement?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        stack.append(RawElement(name: elementName, attributes: attributeDict))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1].text += string
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1].text += String(decoding: CDATABlock, as: UTF8.self)
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard var finished = stack.popLast() else { return }
        finished.text = finished.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if stack.isEmpty {
            root = finished
        } else {
            stack[stack.count - 1].children.append(finished)
        }
    }
}
