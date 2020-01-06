import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(APIClientTests.requestTests),
        testCase(APIClientTests.performTests),
        testCase(APIClientTests.apiClientTests),

        testCase(APIRequestTests.apiRequestTests),

        testCase(URLRequestBuilderTests.urlRequestBuilderTests)
    ]
}
#endif
