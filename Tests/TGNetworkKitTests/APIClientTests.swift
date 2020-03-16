import XCTest
@testable import TGNetworkKit
import Combine

final class APIClientTests: XCTestCase {

    let validResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 200, httpVersion: nil, headerFields: nil
    )
    let redirectionErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 300, httpVersion: nil, headerFields: nil
    )
    let requestErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 400, httpVersion: nil, headerFields: nil
    )
    let serverErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 500, httpVersion: nil, headerFields: nil
    )
    let unhandledErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 900, httpVersion: nil, headerFields: nil
    )

    let request = URLRequest(url: URL(fileURLWithPath: "/foo"))

    enum TestError: Error {
        case testError
    }

    let dataUrl = URL(fileURLWithPath: "/data")
    let mockResourseUrl = URL(string: "https://example.com")!
    let errorUrl = URL(fileURLWithPath: "/TestError.testError")

    static var session = URLSession()

    private func makeURLSession() -> URLSession {
        // Data URLs
        URLProtocolMock.dataURLs[dataUrl] = "{\"key\":\"value\"}".data(using: .utf8)!
        URLProtocolMock.dataURLs[mockResourseUrl] = MockResource(id: "101").asData!

        // Error URLs
        URLProtocolMock.errorURLs[errorUrl] = TestError.testError

        // Set up a configuration to use our mock protocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }

    // MARK: - `request()` tests

    func testAPIClientRequestGetMockResource() {
        let exp = expectation(description: "Request is made and model is returned.")

        let client = APIClient(session: self.makeURLSession())
        client.request(apiRequest: MockAPIRequest()) { result in
            exp.fulfill()

            var resource: MockResource?
            if case .success(let value) = result {
                resource = value
            }

            XCTAssertNotNil(resource)
            XCTAssertEqual(resource, MockResource(id: "101"))
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientRequestThrowingAPIRequest() {
        let exp = expectation(description: "Request is made and model is returned.")

        let client = APIClient(session: self.makeURLSession())
        let apiRequest = MockAPIRequest(host: "example.com", path: "auth/login")
        client.request(apiRequest: apiRequest) { result in
            exp.fulfill()

            var errorToTest: APIError?
            if case .failure(let error) = result {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }

        wait(for: [exp], timeout: 3.0)
    }

    static var requestTests = [
        ("testAPIClientRequestGetMockResource", testAPIClientRequestGetMockResource),
        ("testAPIClientRequestThrowingAPIRequest", testAPIClientRequestThrowingAPIRequest)
    ]

    // MARK: - `perform()` tests

    // This session is injected with an error, triggering `if let error`
    func testAPIClientPerformNetworkingError() {
        let client = APIClient(session: self.makeURLSession())
        client.perform(request: URLRequest(url: self.errorUrl)) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .networkingError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail.")
        }
    }

    static var performTests = [
        ("testAPIClientPerformNetworkingError", testAPIClientPerformNetworkingError),
    ]

    // MARK: - `handleDataTask()` tests

    func testAPIClientHandleDataTaskData() {
        let client = APIClient()
        let data = "".data(using: .utf8)!
        client.handleDataTask(data, response: validResponse, error: nil) { result in
            var dataToTest: Data?
            if case .success(let data) = result {
                dataToTest = data
            }

            XCTAssertNotNil(dataToTest)
        }
    }

    func testAPIClientHandleDataTaskError() {
        let client = APIClient()
        let error = MockError.failed("Test must fail!")
        client.handleDataTask(nil, response: nil, error: error) { result in
            var errorToTest: Error?
            if case .failure(let error) = result, case .networkingError(let err) = error {
                XCTAssertTrue(err is MockError)
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }
    }

    func testAPIClientHandleDataTaskInvalidHTTResponse() {
        let client = APIClient()
        let data = "Data".data(using: .utf8)
        let response = URLResponse()
        client.handleDataTask(data, response: response, error: nil) { result in
            var errorToTest: Error?
            if case .failure(let error) = result, case .invalidResponse = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }
    }

    func testAPIClientHandleDataTaskRedirectionError() {
        let client = APIClient()
        client.handleDataTask(nil, response: redirectionErrorResponse, error: nil) { result in
            var errorToTest: Error?
            if case .failure(let error) = result, case .redirectionError(let code, _) = error {
                XCTAssertEqual(code, 300)
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }
    }

    func testAPIClientHandleDataTaskRequestError() {
        let client = APIClient()
        client.handleDataTask(nil, response: requestErrorResponse, error: nil) { result in
            var errorToTest: Error?
            if case .failure(let error) = result, case .requestError(let code, _) = error {
                XCTAssertEqual(code, 400)
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }
    }

    func testAPIClientHandleDataTaskServerError() {
        let client = APIClient()
        client.handleDataTask(nil, response: serverErrorResponse, error: nil) { result in
            var errorToTest: Error?
            if case .failure(let error) = result, case .serverError(let code, _) = error {
                XCTAssertEqual(code, 500)
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }
    }

    func testAPIClientHandleDataTaskUnhandledHTTPStatusError() {
        let client = APIClient()
        client.handleDataTask(nil, response: unhandledErrorResponse, error: nil) { result in
            var errorToTest: Error?
            if case .failure(let error) = result, case .unhandledHTTPStatus(let code, _) = error {
                XCTAssertEqual(code, 900)
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)
        }
    }

    static var handleDataTaskTests = [
        ("testAPIClientHandleDataTaskData", testAPIClientHandleDataTaskData),
        ("testAPIClientHandleDataTaskError", testAPIClientHandleDataTaskError),
        ("testAPIClientHandleDataTaskInvalidHTTResponse", testAPIClientHandleDataTaskInvalidHTTResponse),
        ("testAPIClientHandleDataTaskRedirectionError", testAPIClientHandleDataTaskRedirectionError),
        ("testAPIClientHandleDataTaskRequestError", testAPIClientHandleDataTaskRequestError),
        ("testAPIClientHandleDataTaskServerError", testAPIClientHandleDataTaskServerError),
        ("testAPIClientHandleDataTaskUnhandledHTTPStatusError", testAPIClientHandleDataTaskUnhandledHTTPStatusError)
    ]

    // MARK: - `parseDecodable()` tests

    func testAPIClientParseDecodableSuccess() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let resource = MockResource(id: "1")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(resource)

        let result: Result<Data?, APIError> = .success(data)

        let client = APIClient()
        client.parseDecodable(result: result) { (result: Result<MockResource, APIError> ) in
            exp.fulfill()
            var resource: MockResource?
            if case .success(let value) = result {
                resource = value
            }

            XCTAssertNotNil(resource, "Success result did not return data")
            XCTAssertEqual(resource?.id, "1")
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientParseDecodableSuccessIsDecodableError() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let result: Result<Data?, APIError> = .success("BadData".data(using: .utf8)!)

        let client = APIClient()
        client.parseDecodable(result: result) { (result: Result<MockResource, APIError> ) in
            exp.fulfill()
            var errorToTest: APIError?
            if case .failure(let error) = result, case .decodingError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientParseDecodableSuccessParseError() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let result: Result<Data?, APIError> = .success(nil)

        let client = APIClient()
        client.parseDecodable(result: result) { (result: Result<MockResource, APIError> ) in
            exp.fulfill()
            var errorToTest: APIError?
            if case .failure(let error) = result, case .parseError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientParseDecodableFailure() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let error = APIError.invalidResponse
        let result: Result<Data?, APIError> = .failure(error)

        let client = APIClient()
        client.parseDecodable(result: result) { (result: Result<MockResource, APIError> ) in
            exp.fulfill()
            var errorToTest: APIError?
            if case .failure(let error) = result, case .invalidResponse = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }

        wait(for: [exp], timeout: 3.0)
    }

    static var parseDecodableTests = [
        ("testAPIClientParseDecodableSuccess", testAPIClientParseDecodableSuccess),
        ("testAPIClientParseDecodableSuccessIsDecodableError", testAPIClientParseDecodableSuccessIsDecodableError),
        ("testAPIClientParseDecodableSuccessParseError", testAPIClientParseDecodableSuccessParseError),
        ("testAPIClientParseDecodableFailure", testAPIClientParseDecodableFailure)
    ]
}
