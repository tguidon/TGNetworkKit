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

    let dataURL = URL(fileURLWithPath: "/data")
    let mockResourceUrl = URL(string: "https://example.com")!
    let badMockResourceUrl = URL(string: "https://example.com/bad-data")!
    let errorURL = URL(string: "https://example.com/error")!
    let apiErrorURL = URL(string: "https://example.com/api-error")!

    private var cancellables = Set<AnyCancellable>()

    private func makeURLSession() -> URLSession {
        // Data URLs
        URLProtocolMock.dataURLs[dataURL] = "{\"key\":\"value\"}".data(using: .utf8)!
        URLProtocolMock.dataURLs[mockResourceUrl] = MockResource(id: "101").asData!
        URLProtocolMock.dataURLs[badMockResourceUrl] = "{\"this_isnt_right\":bool}".data(using: .utf8)!
        URLProtocolMock.dataURLs[apiErrorURL] = "{\"key\":\"value\"}".data(using: .utf8)!//APIError.requestError(400, "Fail fail".data(using: .utf8))

        // Error URLs
        URLProtocolMock.errorURLs[errorURL] = TestError.testError

        // Set up a configuration to use our mock protocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }

    // MARK: - `makeRequest()` tests

    func testAPIClientMakeRequestSuccess() {
        let exp = expectation(description: "Request is made and a response is returned.")

        let client = APIClient(session: self.makeURLSession())
        client.makeRequest(APIRequest.buildMock()) { (result: Result<APIResponse<MockResource>, APIError>) in
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

    func testAPIClientMakeRequestFailure() {
        let exp = expectation(description: "Request is made and request builder error is returned")

        let client = APIClient(session: self.makeURLSession())
        let apiRequest = APIRequest.buildMock(host: "example.com", path: "auth/login")
        client.makeRequest(apiRequest) { (result: Result<APIResponse<MockResource>, APIError>) in
            var errorToTest: APIError?
            if case .failure(let error) = result {
                errorToTest = error
            }

            XCTAssertEqual(APIError.failedToBuildURLRequestURL, errorToTest)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientMakeRequestFailurePerformDataTaskError() {
        let exp = expectation(description: "Request is made and url sessis returned.")

        let client = APIClient(session: self.makeURLSession())
        let apiRequest = APIRequest.buildMock(path: "/api-error")
        client.makeRequest(apiRequest) { (result: Result<APIResponse<MockResource>, APIError>) in
            var errorToTest: APIError?
            if case .failure(let error) = result {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientMakeRequestFailureValidation() {
        let exp = expectation(description: "Request is made and validation fails returned.")

        let client = APIClient(session: self.makeURLSession())
        let apiRequest = APIRequest.buildMock(path: "/error")
        client.makeRequest(apiRequest) { (result: Result<APIResponse<MockResource>, APIError>) in
            var errorToTest: APIError?
            if case .failure(let error) = result {
                errorToTest = error
            }

            XCTAssertNotNil(errorToTest)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientAsyncMakeRequestSuccess() async throws {
        let client = APIClient(session: self.makeURLSession())
        let response: APIResponse<MockResource> = try await client.makeRequest(APIRequest.buildMock())

        XCTAssertEqual(response.value.id, "101")
    }

    func testAPIClientAsyncMakeRequestFailure() async throws {
        let client = APIClient(session: self.makeURLSession())
        let apiRequest = APIRequest.buildMock(host: "example.com", path: "auth/login")
        do {
            let _: APIResponse<MockResource> = try await client.makeRequest(apiRequest)
        } catch {
            guard let errorToTest = error as? APIError else {
                XCTFail("Did not cast to APIError"); return
            }
            XCTAssertEqual(APIError.failedToBuildURLRequestURL, errorToTest)
        }
    }

    func testAPIClientAsyncMakeRequestFailurePerformDataTaskError() async {
        let client = APIClient(session: self.makeURLSession())
        let apiRequest = APIRequest.buildMock(path: "/api-error")
        do {
            let _: APIResponse<MockResource> = try await client.makeRequest(apiRequest)
        } catch {
            XCTAssertNotNil(error as? APIError)
        }
    }

    static var requestTests = [
        ("testAPIClientMakeRequestSuccess", testAPIClientMakeRequestSuccess),
        ("testAPIClientMakeRequestFailure", testAPIClientMakeRequestFailure),
        ("testAPIClientMakeRequestFailurePerformDataTaskError", testAPIClientMakeRequestFailurePerformDataTaskError),
        ("testAPIClientMakeRequestFailureValidation", testAPIClientMakeRequestFailureValidation),

        ("testAPIClientAsyncMakeRequestSuccess", testAPIClientAsyncMakeRequestSuccess),
        ("testAPIClientAsyncMakeRequestFailure", testAPIClientAsyncMakeRequestFailure),
        ("testAPIClientAsyncMakeRequestFailurePerformDataTaskError", testAPIClientAsyncMakeRequestFailurePerformDataTaskError)
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
        let publisher: TestPublisher = client.makeRequestPublisher(apiRequest)
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

        let publisher: AnyPublisher<APIResponse<MockResource>, APIError> = client.makeRequestPublisher(apiRequest)
        let cancellable = publisher.sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
                XCTFail()
            case .failure(let error):
                print(error)
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

        let publisher: AnyPublisher<APIResponse<MockResource>, APIError> = client.makeRequestPublisher(apiRequest)
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

        let publisher: AnyPublisher<APIResponse<MockResource>, APIError> = client.makeRequestPublisher(apiRequest)
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
