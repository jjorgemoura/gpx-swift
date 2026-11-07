import Foundation

#if canImport(FoundationXML)
    import FoundationXML
#endif

/// Builds a ``RawElement`` tree iteratively, so deep documents cannot overflow the stack.
final class TreeBuilder: NSObject, XMLParserDelegate {
    private var stack: [RawElement] = []
    private(set) var root: RawElement?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String]
    ) {
        stack.append(RawElement(name: elementName, attributes: attributeDict))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1].text += string
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard !stack.isEmpty else { return }
        stack[stack.count - 1].text += String(bytes: CDATABlock, encoding: .utf8) ?? ""
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
