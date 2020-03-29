import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(APIClientTests.requestTests),
        testCase(APIClientTests.performTests),
        testCase(APIClientTests.handleDataTaskTests),
        testCase(APIClientTests.parseDecodableTests),
        testCase(APIClientTests.combineTests),

        testCAse(APIErrorTests.apiErrorTests),

        testCase(APIRequestTests.apiRequestTests),

        testCase(ErrorExtensionTests.errorExtensionTests),

        testCase(URLRequestBuilderTests.urlRequestBuilderTests)
    ]
}
#endif
