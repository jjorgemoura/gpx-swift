import Foundation
import Testing

@testable import GPXSwift

enum TestHelpers {
    static func fixture(_ name: String) throws -> GPXDocument {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "gpx", subdirectory: "Fixtures"))
        return try GPXDocument(contentsOf: url)
    }

    static func date(_ iso: String) throws -> Date {
        try #require(GPXDateCoding.parse(iso))
    }
}
