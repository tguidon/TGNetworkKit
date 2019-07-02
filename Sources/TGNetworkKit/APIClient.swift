//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation

/// API Client for making Requestable requests
final public class APIClient {

    // Data Response Result
    typealias DataResultCompletion = (Result<Data, APIError>) -> Void

    // Defaults to shared URLSession
    private let session: URLSession

    // JSONDecoder for handling responses
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        if useSnakeCaseDecoding {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        return decoder
    }

    // Set value to false to not convert from snake case
    public var useSnakeCaseDecoding: Bool = true

    /**
     Initializes a new API client with a shared session by default

     - Parameters:
        - session: URLSession to use in client
     */
    init(session: URLSession = .shared) {
        self.session = session
    }

    /**
     Makes requests that confirm to the Requestable protocol

     - Parameters:
        - model: The concrete Requestable type
        - method: HTTPMethod to use in quest, the default is a GET
        - completion: Handler resolves with Result<T: APIError>
     */
    public func makeRequest<T: Requestable>(
        _ model: T.Type, method: HTTPMethod = .get, completion: @escaping (Result<T, APIError>) -> Void
    ) {
        var request = T.makeRequest()
        request.httpMethod = method.rawValue
        perform(request: request) { result in
            self.parseDecodable(result: result, completion: completion)
        }
    }

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
    private func handleDataTask(
        _ data: Data?, response: URLResponse?, error: Error?, completion: @escaping DataResultCompletion
    ) {
        if let error = error  {
            completion(.failure(.networkingError(error)))
            return
        }

        guard let http = response as? HTTPURLResponse, let data = data else {
            completion(.failure(.invalidResponse))
            return
        }

        let body = String(data: data, encoding: .utf8) ?? "<no body>"
        switch http.statusCode {
        case 200...299:
            completion(.success(data))
        case 300...399:
            completion(.failure(.redirectionError(http.statusCode, body)))
        case 400...499:
            completion(.failure(.requestError(http.statusCode, body)))
        case 500...599:
            completion(.failure(.serverError(http.statusCode, body)))
        default:
            completion(.failure(.unhandledHTTPStatus(http.statusCode, body)))
        }
    }

    /**
     Parses the data response into a response of T: Decodable

     - Parameters:
         - result: Result<Data, APIError>
         - completion: Handler resoleves with Result<T: APIError>
     */
    internal func parseDecodable<T: Decodable>(result: Result<Data, APIError>, completion: @escaping (Result<T, APIError>) -> Void) {
        switch result {
        case .success(let data):
            do {
                let object = try jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch let decodingError as DecodingError {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(decodingError)))
                }
            } catch let error {
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
