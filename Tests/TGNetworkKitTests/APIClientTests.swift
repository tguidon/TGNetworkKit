import XCTest
@testable import TGNetworkKit

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var response: URLResponse?
    var error: Error?

    override func dataTask(
        with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        let data = self.data
        let response = self.response
        let error = self.error

        let dataTask = URLSessionDataTaskMock {
            completionHandler(data, response, error)
        }

        return dataTask
    }
}

final class APIClientTests: XCTestCase {

    let validResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 200, httpVersion: nil, headerFields: nil
    )
    let redirectionErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 300, httpVersion: nil, headerFields: nil
    )
    let requestErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 403, httpVersion: nil, headerFields: nil
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

    func testAPIClientRequestGET() {
        let exp = expectation(description: "Request is made and model is returned.")

        let resource = MockResource(id: "1")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(resource)

        let session = URLSessionMock()
        session.response = validResponse
        session.data = data

        let apiRequest = MockAPIRequest()
        let client = APIClient(session: session)
        client.request(apiRequest: apiRequest) { result in
            exp.fulfill()

            var resource: MockResource?
            if case .success(let value) = result {
                resource = value
            }

            XCTAssertNotNil(resource)
        }

        wait(for: [exp], timeout: 3.0)
    }

    static var requestTests = [
        ("testAPIClientRequestGET", testAPIClientRequestGET),
    ]


    // This session is injected with an error, triggering `if let error`
    func testAPIClientPerformNetworkingError() {
        let session = URLSessionMock()
        session.error = TestError.testError

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .networkingError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail.")
        }

    }

    // This session is injected with nothing, triggering `guard http`
    func testAPIClientPerformInvalidResponseNoResponse() {
        let session = URLSessionMock()

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .invalidResponse = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail.")
        }
    }

    // This session is injected with no data, triggering `guard http`
    func testAPIClientPerformInvalidResponseNoData() {
        let session = URLSessionMock()
        session.response = validResponse

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .invalidResponse = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail.")
        }
    }

    func testAPIClientPerformRedirectionError() {
        let session = URLSessionMock()
        session.response = redirectionErrorResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .redirectionError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail.")
        }
    }

    func testAPIClientPerformRequestError() {
        let session = URLSessionMock()
        session.response = requestErrorResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .requestError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail.")
        }
    }

    func testAPIClientPerformServerError() {
        let session = URLSessionMock()
        session.response = serverErrorResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .serverError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }
    }

    func testAPIClientPerformUnhandledError() {
        let session = URLSessionMock()
        session.response = unhandledErrorResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var errorToTest: APIError?
            if case .failure(let error) = result, case .unhandledHTTPStatus = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }
    }

    // This session is injected with a valid response and data, triggering Result success
    func testAPIClientPerformSuccess() {
        let session = URLSessionMock()
        session.response = validResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            var dataToTest: Data?
            if case .success(let data) = result {
                dataToTest = data
            }

            XCTAssertNotNil(dataToTest, "Success result did not return data")
        }
    }

    static var performTests = [
        ("testAPIClientPerformNetworkingError", testAPIClientPerformNetworkingError),
        ("testAPIClientPerformInvalidResponse", testAPIClientPerformInvalidResponseNoResponse),
        ("testAPIClientPerformInvalidResponseNoData", testAPIClientPerformInvalidResponseNoData),
        ("testAPIClientPerformRedirectionError", testAPIClientPerformRedirectionError),
        ("testAPIClientPerformRequestError", testAPIClientPerformRequestError),
        ("testAPIClientPerformServerError", testAPIClientPerformServerError),
        ("testAPIClientPerformUnhandledError", testAPIClientPerformUnhandledError),
        ("testAPIClientPerformSuccess", testAPIClientPerformSuccess)
    ]

    func testAPIClientParseDecodableSuccess() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let resource = MockResource(id: "1")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(resource)

        let client = APIClient()

        let resultParam: Result<Data, APIError> = .success(data)

        client.parseDecodable(result: resultParam) { (result: Result<MockResource, APIError> ) in
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

    func testAPIClientParseDecodableResultIsDecodableError() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let client = APIClient()
        let resultParam: Result<Data, APIError> = .success("BadData".data(using: .utf8)!)

        client.parseDecodable(result: resultParam) { (result: Result<MockResource, APIError> ) in
            exp.fulfill()
            var errorToTest: APIError?
            if case .failure(let error) = result, case .decodingError = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientParseDecodableResultIsPassingError() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let client = APIClient()
        let resultParam: Result<Data, APIError> = .failure(APIError.invalidResponse)

        client.parseDecodable(result: resultParam) { (result: Result<MockResource, APIError> ) in
            exp.fulfill()
            var errorToTest: APIError?
            if case .failure(let error) = result, case .invalidResponse = error {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest, "Proper APIError was not returned, or result did not fail")
        }

        wait(for: [exp], timeout: 3.0)
    }

    static var apiClientTests = [
        ("testAPIClientParseDecodableSuccess", testAPIClientParseDecodableSuccess),
        ("testAPIClientParseDecodableResultIsDecodableError", testAPIClientParseDecodableResultIsDecodableError),
        ("testAPIClientParseDecodableResultIsPassingError", testAPIClientParseDecodableResultIsPassingError)
    ]
}
