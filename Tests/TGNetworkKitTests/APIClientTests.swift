import XCTest
@testable import TGNetworkKit
import Combine

@available(OSX 10.15, *)
@available(iOS 13.0, *)
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

    let dataURL = URL(fileURLWithPath: "/data")
    let mockResourceUrl = URL(string: "https://example.com")!
    let badMockResourceUrl = URL(string: "https://example.com/bad-data")!
    let errorURL = URL(fileURLWithPath: "/TestError.testError")
    let apiErrorURL = URL(fileURLWithPath: "https://example.com/api-error")

    private var cancellables = Set<AnyCancellable>()

    private func makeURLSession() -> URLSession {
        // Data URLs
        URLProtocolMock.dataURLs[dataURL] = "{\"key\":\"value\"}".data(using: .utf8)!
        URLProtocolMock.dataURLs[mockResourceUrl] = MockResource(id: "101").asData!
        URLProtocolMock.dataURLs[badMockResourceUrl] = "{\"this_isnt_right\":bool}".data(using: .utf8)!

        // Error URLs
        URLProtocolMock.errorURLs[errorURL] = TestError.testError
        URLProtocolMock.errorURLs[apiErrorURL] = APIError.requestError(400, "Fail fail".data(using: .utf8))

        // Set up a configuration to use our mock protocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }

    // MARK: - `execute()` tests

    func testAPIClientExecuteRequestSuccess() {
        let exp = expectation(description: "Request is made and model is returned.")

        let client = APIClient(session: self.makeURLSession())
        client.execute(request: APIRequest.buildMock()) { (result: Result<APIResponse<MockResource>, APIError>) in
            var resource: MockResource?
            if case .success(let response) = result {
                resource = response.value
            }

            XCTAssertNotNil(resource)
            XCTAssertEqual(resource, MockResource(id: "101"))

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientExecuteRequestFailure() {
        let exp = expectation(description: "Request is made and model is returned.")

        let client = APIClient(session: self.makeURLSession())
        let apiRequest = APIRequest.buildMock(host: "example.com", path: "auth/login")
        client.execute(request: apiRequest) { (result: Result<APIResponse<MockResource>, APIError>) in
            var errorToTest: APIError?
            if case .failure(let error) = result {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientExecuteRequestFailurePerformDataTaskError() {
        XCTFail()
    }

    func testAPIClientExecuteRequestFailureValidation() {
        XCTFail()
    }

    static var requestTests = [
        ("testAPIClientExecuteRequestSuccess", testAPIClientExecuteRequestSuccess),
        ("testAPIClientExecuteRequestFailure", testAPIClientExecuteRequestFailure),
        ("testAPIClientExecuteRequestFailurePerformDataTaskError", testAPIClientExecuteRequestFailurePerformDataTaskError),
        ("testAPIClientExecuteRequestFailureValidation", testAPIClientExecuteRequestFailureValidation)
    ]

    // MARK: - `performDataTask()` tests

    // This session is injected with an error, triggering `if let error`
    func testAPIClientPerformNetworkingError() {
        let client = APIClient(session: self.makeURLSession())
        client.performDataTask(request: URLRequest(url: self.errorURL)) { (data, urlResponse, error) in
            XCTAssertNotNil(error, "Proper APIError was not returned, or result did not fail.")
        }
    }

    static var performTests = [
        ("testAPIClientPerformNetworkingError", testAPIClientPerformNetworkingError),
    ]

    // MARK: - `adapt()` tests

    func testAPIClientAdaptURLRequest() {
        struct TestAdapter: RequestAdapter {
            func adapt(_ urlRequest: inout URLRequest) {
                urlRequest.url = URL(string: "adapted.com")
            }
        }
        let client = APIClient(session: self.makeURLSession(), requestAdapters: [TestAdapter()])
        let url = URL(string: "example.com")!
        var urlRequest = URLRequest(url: url)
        client.adapt(&urlRequest)

        XCTAssertEqual(urlRequest.url, URL(string: "adapted.com"))
    }

    static var adaptTests = [
        ("testAPIClientAdaptURLRequest", testAPIClientAdaptURLRequest),
    ]

    // MARK: - Validation and Response Tests

    func testAPIClientValidateResponseNoThrow() {
        let resource = MockResource(id: "1")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(resource)

        let client = APIClient()
        XCTAssertNoThrow(try client.validateResponse(data: data, response: self.validResponse))
    }

    func testAPIClientValidateResponseNoThrowNoContent() {
        let client = APIClient()
        XCTAssertNoThrow(try client.validateResponse(data: nil, response: self.validResponse))
    }

    func testAPIClientValidateResponseInvalidHTTResponse() {
        let data = "Data".data(using: .utf8)!

        let client = APIClient()
        XCTAssertThrowsError(try client.validateResponse(data: data, response: URLResponse()))
    }

    func testAPIClientValidateResponseRedirectionError() {
        let data = "Data".data(using: .utf8)!

        let client = APIClient()
        XCTAssertThrowsError(try client.validateResponse(data: data, response: self.redirectionErrorResponse))
    }

    func testAPIClientValidateResponseRequestError() {
        let data = "Data".data(using: .utf8)!

        let client = APIClient()
        XCTAssertThrowsError(try client.validateResponse(data: data, response: self.requestErrorResponse))
    }

    func testAPIClientValidateResponseServerError() {
        let data = "Data".data(using: .utf8)!

        let client = APIClient()
        XCTAssertThrowsError(try client.validateResponse(data: data, response: self.serverErrorResponse))
    }

    func testAPIClientValidateResponseUnhandledError() {
        let data = "Data".data(using: .utf8)!

        let client = APIClient()
        XCTAssertThrowsError(try client.validateResponse(data: data, response: self.unhandledErrorResponse))
    }

    static var validationTests = [
        ("testAPIClientValidateResponseNoThrow", testAPIClientValidateResponseNoThrow),
        ("testAPIClientValidateResponseNoThrowNoContent", testAPIClientValidateResponseNoThrowNoContent),
        ("testAPIClientValidateResponseInvalidHTTResponse", testAPIClientValidateResponseInvalidHTTResponse),
        ("testAPIClientValidateResponseRedirectionError", testAPIClientValidateResponseRedirectionError),
        ("testAPIClientValidateResponseRequestError", testAPIClientValidateResponseRequestError),
        ("testAPIClientValidateResponseServerError", testAPIClientValidateResponseServerError),
        ("testAPIClientValidateResponseUnhandledError", testAPIClientValidateResponseUnhandledError)
    ]

    // MARK: - Combine Tests

    func testAPIClientDataTaskPublisherFinishedSuccessfully() {
        let exp = XCTestExpectation(description: "Waiting for data task publisher to return successfully")

        let apiRequest = APIRequest.buildMock()

        let client = APIClient(session: self.makeURLSession())

        typealias TestPublisher = AnyPublisher<APIResponse<MockResource>, APIError>
        let publisher: TestPublisher = client.buildPublisher(for: apiRequest)
        let cancellable = publisher.sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
                exp.fulfill()
            case .failure:
                XCTFail()
            }
        }, receiveValue: { apiResponse in
            XCTAssertEqual(apiResponse.value.id, "101")
        })
        cancellable.store(in: &self.cancellables)

        wait(for: [exp], timeout: 2.0)
    }

    func testAPIClientDataTaskPublisherFailureAPIError() {
        let exp = XCTestExpectation(description: "Waiting for data task publisher to return successfully")

        let apiRequest = APIRequest.buildMock(path: "/api-error")

        let client = APIClient(session: self.makeURLSession())

        let publisher: AnyPublisher<APIResponse<MockResource>, APIError> = client.buildPublisher(for: apiRequest)
        let cancellable = publisher.sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
                XCTFail()
            case .failure:
                exp.fulfill()
            }
        }, receiveValue: { apiResponse in
            XCTFail("No value should be received")
        })
        cancellable.store(in: &self.cancellables)

        wait(for: [exp], timeout: 2.0)
    }

    func testAPIClientDataTaskPublisherFailureDecoding() {
        let exp = XCTestExpectation(description: "Waiting for decoding failure")

        let apiRequest = APIRequest.buildMock(path: "/bad-data")

        let client = APIClient(session: self.makeURLSession())

        let publisher: AnyPublisher<APIResponse<MockResource>, APIError> = client.buildPublisher(for: apiRequest)
        let cancellable = publisher.sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
                XCTFail()
            case .failure:
                exp.fulfill()
            }
        }, receiveValue: { apiResponse in
            XCTFail("No value should be received")
        })
        cancellable.store(in: &self.cancellables)

        wait(for: [exp], timeout: 2.0)
    }

    func testAPIClientDataTaskPublisherFailureBuildingURLRequest() {
        let exp = XCTestExpectation(description: "Waiting for decoding failure")

        let apiRequest = APIRequest.buildMock(path: "bad-url-build")

        let client = APIClient(session: self.makeURLSession())

        let publisher: AnyPublisher<APIResponse<MockResource>, APIError> = client.buildPublisher(for: apiRequest)
        let cancellable = publisher.sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
                XCTFail()
            case .failure:
                exp.fulfill()
            }
        }, receiveValue: { apiResponse in
            XCTFail("No value should be received")
        })
        cancellable.store(in: &self.cancellables)

        wait(for: [exp], timeout: 2.0)
    }


    static var combineTests = [
        ("testAPIClientDataTaskPublisherFinishedSuccessfully", testAPIClientDataTaskPublisherFinishedSuccessfully),
        ("testAPIClientDataTaskPublisherFailureAPIError", testAPIClientDataTaskPublisherFailureAPIError),
        ("testAPIClientDataTaskPublisherFailureDecoding", testAPIClientDataTaskPublisherFailureDecoding),
        ("testAPIClientDataTaskPublisherFailureBuildingURLRequest", testAPIClientDataTaskPublisherFailureBuildingURLRequest)
    ]
}
