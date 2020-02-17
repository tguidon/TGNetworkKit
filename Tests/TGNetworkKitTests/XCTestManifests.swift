import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(APIClientTests.requestTests),
        testCase(APIClientTests.performTests),
        testCase(APIClientTests.handleDataTaskTests),
        testCase(APIClientTests.parseDecodableTests),

        testCase(APIRequestTests.apiRequestTests),

        testCase(URLRequestBuilderTests.urlRequestBuilderTests)
    ]
}
#endif
