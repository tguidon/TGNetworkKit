//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation
import Combine

/// API Client for making Requestable requests
final public class APIClient {

    /// Data Response Result
    typealias DataResultCompletion = (Result<Data?, APIError>) -> Void

    /// Defaults to shared URLSession
    private let session: URLSession

    /// URLRequest builder for all requests
    private let requestBuilder: RequestBuilder

    /// JSONDecoder for handling responses
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        if useSnakeCaseDecoding {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        return decoder
    }

    /// Set value to false to not convert from snake case
    public var useSnakeCaseDecoding: Bool = true

    /// Number of retries api publisher returned
    public var numberOfRetries: Int = 0

    /**
     Initializes a new API client with a shared session by default

     - Parameters:
        - session: URLSession to use in client
     */
    init(session: URLSession = .shared, requestBuilder: RequestBuilder = URLRequestBuilder()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }

    /**
     Makes requests that confirm to the Requestable protocol

     - Parameters:
        - model: The concrete Requestable type
        - method: HTTPMethod to use in quest, the default is a GET
        - completion: Handler resolves with Result<T: APIError>
     */
    public func request<T: APIRequest>(apiRequest: T, completion: @escaping (Result<T.Resource, APIError>) -> Void) {
        /// Create the `urlRequest` and on success, perform the request
        do {
            let request = try requestBuilder.build(apiRequest: apiRequest)
            perform(request: request) { result in
                self.parseDecodable(result: result, completion: completion)
            }
        } catch let error as APIError {
            completion(.failure(error))
        } catch {
            completion(.failure(APIError.unhandled))
        }
    }


//    @available(iOS 13.0, *)
//    @available(OSX 10.15, *)
//    public func build<T: APIRequest>(apiRequest: T) -> AnyPublisher<T.Resource, APIError> {
//
//    }
//
//    @available(iOS 13.0, *)
//    @available(OSX 10.15, *)
//    public func buildRequestPublisher<T: APIRequest>(apiRequest: T) -> AnyPublisher<APIResponse<T.Resource>, Error> {
//        do {
//            // Create the url request from the given `APIRequest` protocol
//            let request = try requestBuilder.build(apiRequest: apiRequest)
//            // URLSession data task publisher, maps data as `APIResponse`
//            return self.session
//                .dataTaskPublisher(for: request)
//                .retry(self.numberOfRetries)
//                .tryMap { result -> APIResponse<T.Resource> in
//                    let value = try self.jsonDecoder.decode(T.Resource.self, from: result.data)
//                    return APIResponse(value: value, response: result.response)
//                }
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//        } catch let error {
//            return Fail<APIResponse<T.Resource>, Error>(error: error)
//                .eraseToAnyPublisher()
//        }
//    }

    /**
     Performs the URLRequest and handles the data task. Fires off the task.

     - Parameters:
         - request: URLRequest passed in from makeRequest method
         - completion: Handler resolves with Result<Data: APIError>
     */
    internal func perform(request: URLRequest, completion: @escaping DataResultCompletion) {
        let task = session.dataTask(with: request) { (data, response, error) in
            self.handleDataTask(data, response: response, error: error, completion: completion)
        }
        task.resume()
    }

    /**
     Handles the bulk of the API Client data task. Verifies if the data, response, and error are valid
     and calls the completion handler upon verification.

     - Parameters:
         - data: Optional Data from data task
         - response: Optional URLResponse from the data task
         - error: Optional Error from the data task
         - completion: Handler resolves with Result<Data: APIError>

     */
    internal func handleDataTask(_ data: Data?, response: URLResponse?, error: Error?, completion: @escaping DataResultCompletion) {
        if let error = error  {
            completion(.failure(.networkingError(error)))
            return
        }

        guard let http = response as? HTTPURLResponse else {
            completion(.failure(.invalidResponse))
            return
        }

        let errorData = data ?? "No error response".data(using: .utf8)!
        let errorResponse = String(data: errorData, encoding: .utf8)
        switch http.statusCode {
        case 200...299:
            completion(.success(data))
        case 300...399:
            completion(.failure(.redirectionError(http.statusCode, errorResponse)))
        case 400...499:
            completion(.failure(.requestError(http.statusCode, errorResponse)))
        case 500...599:
            completion(.failure(.serverError(http.statusCode, errorResponse)))
        default:
            completion(.failure(.unhandledHTTPStatus(http.statusCode, errorResponse)))
        }
    }

    /**
     Parses the data response into a response of T: Decodable

     - Parameters:
         - result: Result<Data, APIError>
         - completion: Handler resoleves with Result<T: APIError>
     */
    internal func parseDecodable<T: Decodable>(result: Result<Data?, APIError>, completion: @escaping (Result<T, APIError>) -> Void) {
        switch result {
        case .success(let data):
            do {
                guard let data = data else { throw APIError.dataIsNil }
                let object = try jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch let error as DecodingError {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.parseError(error)))
                }
            }
        case .failure(let error):
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}
