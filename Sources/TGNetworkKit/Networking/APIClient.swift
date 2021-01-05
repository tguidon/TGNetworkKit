//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation
import Combine

/// API Client for making Requestable requests
final public class APIClient: NetworkingProtocol {

    /// Data Response Result
    typealias DataResultCompletion = (Result<Data?, APIError>) -> Void

    /// Defaults to shared URLSession
    public let session: URLSession
    /// URLRequest builder for all requests
    public let requestBuilder: RequestBuilder
    /// Add additional information to requests
    public let requestAdapters: [RequestAdapter]
    /// Defaults to base `JSONDecoder` initializer
    internal let jsonDecoder: JSONDecoder

    init(
        session: URLSession = .shared,
        requestBuilder: RequestBuilder = URLRequestBuilder(),
        requestAdapters: [RequestAdapter] = [],
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.requestAdapters = requestAdapters
        self.jsonDecoder = jsonDecoder
    }
}

extension APIClient {

    // MARK: - Combine

    /// <#Description#>
    /// - Parameter request: <#request description#>
    /// - Returns: <#description#>
    @available(iOS 13.0, *)
    @available(OSX 10.15, *)
    public func buildPublisher<T: Decodable>(for request: APIRequest) -> AnyPublisher<APIResponse<T>, APIError> {
        guard var urlRequest = requestBuilder.build(apiRequest: request) else {
            return Fail<APIResponse<T>, APIError>(
                error: APIError.failedToBuildURLRequestURL
            ).eraseToAnyPublisher()
        }

        self.adapt(&urlRequest)

        return self.session.dataTaskPublisher(for: urlRequest)
            .tryMap(self.validateResponse)
            .tryMap(self.buildResponse)
            .mapError(APIError.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Adapts the given `URLRequest` via the given Apaptor array on client init.
    internal func adapt(_ urlRequest: inout URLRequest) {
        self.requestAdapters.forEach { $0.adapt(&urlRequest) }
    }

    // MARK: - Result

    /**
     Makes requests that confirm to the Requestable protocol

     - Parameters:
        - model: The concrete Requestable type
        - method: HTTPMethod to use in quest, the default is a GET
        - completion: Handler resolves with Result<T: APIError>
     */
    public func execute<T: Decodable>(request: APIRequest, completion: @escaping (Result<APIResponse<T>, APIError>) -> Void) {
        guard let request = requestBuilder.build(apiRequest: request) else {
            completion(.failure(APIError.failedToBuildURLRequestURL)); return
        }

        self.performDataTask(request: request) { (data, urlResponse, error) in
            guard error == nil else {
                completion(.failure(error!.asAPIError)); return
            }

            do {
                let (data, httpURLResponse) = try self.validateResponse(data: data, response: urlResponse)
                let response: APIResponse<T> = try self.buildResponse(forData: data, httpURLResponse: httpURLResponse)
                completion(.success(response))
            } catch {
                completion(.failure(error .asAPIError))
            }
        }
    }

    /**
     Performs the URLRequest and handles the data task. Fires off the task.

     - Parameters:
         - request: URLRequest passed in from makeRequest method
         - completion: Handler resolves with Result<Data: APIError>
     */
    internal func performDataTask(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            completion(data, urlResponse, error)
        }
        task.resume()
    }

    // MARK:- Shared Logic

    /// Returns a `(Data, HTTPURLResponse)` tuple upon successful validate. All HTTP responses between
    /// 200-299 are considered valid.
    ///
    /// - Parameters:
    ///     - data: `Data` returned from `dataTaskPublisher`
    ///     - response: `URLResponse` returned from `dataTaskPublisher`
    internal func validateResponse(data: Data?, response: URLResponse?) throws -> (Data, HTTPURLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return (data ?? "No Content".data(using: .utf8)!, httpResponse)
        case 300...399:
            throw APIError.redirectionError(httpResponse.statusCode, data)
        case 400...499:
            throw APIError.requestError(httpResponse.statusCode, data)
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode, data)
        default:
            throw APIError.unhandledHTTPStatus(httpResponse.statusCode, data)
        }
    }

    /// Returns a `Response` object upon successfully decoding the data as a type
    ///
    /// - Parameters:
    ///     - data: `Data` returned from `dataTaskPublisher`
    ///     - httpURLResponse: `HTTPURLResponse` returned upstream
    internal func buildResponse<T: Decodable>(forData data: Data, httpURLResponse: HTTPURLResponse) throws -> APIResponse<T> {
        let value = try self.jsonDecoder.decode(T.self, from: data)
        return APIResponse(value: value, response: httpURLResponse)
    }

}