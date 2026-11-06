import Testing
@testable import GPXSwift

@Suite("GPXSwift")
struct GPXSwiftTests {
    @Test func greeting() {
        #expect(GPXSwift().greeting() == "Hello from GPXSwift")
    }
}
