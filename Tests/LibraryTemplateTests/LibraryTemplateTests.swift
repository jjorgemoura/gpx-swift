import Testing
@testable import LibraryTemplate

@Suite("LibraryTemplate")
struct LibraryTemplateTests {
    @Test func greeting() {
        #expect(LibraryTemplate().greeting() == "Hello from LibraryTemplate")
    }
}
