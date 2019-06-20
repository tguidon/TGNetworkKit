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
    let requestErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 403, httpVersion: nil, headerFields: nil
    )
    let serverErrorResponse = HTTPURLResponse(
        url: URL(fileURLWithPath: "path"), statusCode: 500, httpVersion: nil, headerFields: nil
    )

    let request = URLRequest(url: URL(fileURLWithPath: "/foo"))

    enum TestError: Error {
        case testError
    }

    // This session is injected with an error, triggering `if let error`
    func testAPIClientPerformNetworkingError() {
        let session = URLSessionMock()
        session.error = TestError.testError

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail("There should be no data.")
            case .failure(let error):
                switch error {
                case .networkingError:
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }

    }

    // This session is injected with nothing, triggering `guard http`
    func testAPIClientPerformInvalidResponseNoResponse() {
        let session = URLSessionMock()

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail("There should be no data.")
            case .failure(let error):
                switch error {
                case .invalidResponse:
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }
    }

    // This session is injected with no data, triggering `guard http`
    func testAPIClientPerformInvalidResponseNoData() {
        let session = URLSessionMock()
        session.response = validResponse

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail("There should be no data.")
            case .failure(let error):
                switch error {
                case .invalidResponse:
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }
    }

    func testAPIClientPerformRequestError() {
        let session = URLSessionMock()
        session.response = requestErrorResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail("There should be no data.")
            case .failure(let error):
                switch error {
                case .requestError:
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }
    }

    func testAPIClientPerformServerError() {
        let session = URLSessionMock()
        session.response = serverErrorResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            switch result {
            case .success:
                XCTFail("There should be no data.")
            case .failure(let error):
                switch error {
                case .serverError:
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }
    }

    // This session is injected with a valid response and data, triggering Result success
    func testAPIClientPerformSuccess() {
        let session = URLSessionMock()
        session.response = validResponse
        session.data = "Data".data(using: .utf8)!

        let client = APIClient(session: session)
        client.perform(request: request) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(let error):
                XCTAssertNil(error)
            }
        }
    }

    static var performTests = [
        ("testAPIClientPerformNetworkingError", testAPIClientPerformNetworkingError),
        ("testAPIClientPerformInvalidResponse", testAPIClientPerformInvalidResponseNoResponse),
        ("testAPIClientPerformInvalidResponseNoData", testAPIClientPerformInvalidResponseNoData),
        ("testAPIClientPerformRequestError", testAPIClientPerformRequestError),
        ("testAPIClientPerformServerError", testAPIClientPerformServerError),
        ("testAPIClientPerformSuccess", testAPIClientPerformSuccess)
    ]

    struct TestUser: Codable {
        let name: String
    }

    func testAPIClientParseDecodableSuccess() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let response = TestUser(name: "Taylor")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(response)

        let client = APIClient()

        let resultParam: Result<Data, APIError> = .success(data)

        client.parseDecodable(result: resultParam) { (result: Result<TestUser, APIError> ) in
            exp.fulfill()
            switch result {
            case .success(let user):
                XCTAssertEqual(user.name, "Taylor")
            case .failure(let error):
                dump(error)
                XCTFail()
            }
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientParseDecodableResultIsDecodableError() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let client = APIClient()
        let resultParam: Result<Data, APIError> = .success("BadData".data(using: .utf8)!)

        client.parseDecodable(result: resultParam) { (result: Result<TestUser, APIError> ) in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail("Should not decode any data")
            case .failure(let error):
                switch error {
                case .decodingError:
                    XCTAssert(true)
                default:
                    XCTFail("Did not use Decodable error")
                }
            }
        }

        wait(for: [exp], timeout: 3.0)
    }

    func testAPIClientParseDecodableResultIsPassingError() {
        let exp = expectation(description: "Result is parsed and then sent to DispatchQueue.")

        let client = APIClient()
        let resultParam: Result<Data, APIError> = .failure(APIError.invalidResponse)

        client.parseDecodable(result: resultParam) { (result: Result<TestUser, APIError> ) in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail("Should not decode any data")
            case .failure(let error):
                switch error {
                case .invalidResponse:
                    XCTAssert(true)
                default:
                    XCTFail("Did not use Decodable error")
                }
            }
        }

        wait(for: [exp], timeout: 3.0)
    }

    static var parseTests = [
        ("testAPIClientParseDecodableSuccess", testAPIClientParseDecodableSuccess),
        ("testAPIClientParseDecodableResultIsDecodableError", testAPIClientParseDecodableResultIsDecodableError),
        ("testAPIClientParseDecodableResultIsPassingError", testAPIClientParseDecodableResultIsPassingError)
    ]
}
