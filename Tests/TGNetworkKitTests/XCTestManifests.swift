import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(APIClientTests.performTests),
        testCase(APIClientTests.parseTests)
    ]
}
#endif
