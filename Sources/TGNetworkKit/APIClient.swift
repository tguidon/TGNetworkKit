//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation

final public class APIClient {

    typealias DataResultCompletion = (Result<Data, APIError>) -> Void

    // Defaults to shared session
    private let session: URLSession

    private var jsonDecoder: JSONDecoder {

        let decoder = JSONDecoder()
        if useSnakeCaseDecoding {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        return decoder
    }

    // Set value to false to not convert from snake case
    public var useSnakeCaseDecoding: Bool = true

    init(session: URLSession = .shared) {

        self.session = session
    }

    public func create<T: Creatable>(_ model: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {

        let url = T.baseURL.appendingPathComponent(T.path)
        var request = URLRequest(url: url)
        request.httpMethod = T.httpMethod

        performAndParse(request: request, completion: completion)
    }

    public func fetch<T: Fetchable>(_ model: T.Type, id: T.ID, completion: @escaping (Result<T, APIError>) -> Void) {

        let url = T.baseURL.appendingPathComponent(T.path)
        var request = URLRequest(url: url)
        request.httpMethod = T.httpMethod

        performAndParse(request: request, completion: completion)

//        perform(request: request) { result in
//            self.parseDecodable(result: result, completion: completion)
//        }
    }

    public func update<T: Updatable>(_ model: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {

    }

    public func delete<T: Deletable>(_ model: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {

    }

    private func performAndParse<T: Requestable>(request: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {

        perform(request: request) { result in
            self.parseDecodable(result: result, completion: completion)
        }
    }

    internal func perform(request: URLRequest, completion: @escaping DataResultCompletion) {

        let task = session.dataTask(with: request) { (data, response, error) in
            self.handleDataTask(data, response: response, error: error, completion: completion)
        }
        task.resume()
    }

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
