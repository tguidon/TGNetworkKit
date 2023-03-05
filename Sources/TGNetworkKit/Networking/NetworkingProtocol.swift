//
//  NetworkingProtocol.swift
//  
//
//  Created by Taylor Guidon on 1/3/21.
//

import Foundation
import Combine

/// Protocol used to define the APIClients dependencies and actions
protocol NetworkingProtocol {
    var session: URLSession { get }
    var requestBuilder: RequestBuilder { get }
    var requestAdapters: [RequestAdapter] { get }
    var jsonDecoder: JSONDecoder { get }

    func makeRequest<T: Decodable>(
        _ request: APIRequest,
        completion: @escaping (Result<APIResponse<T>, APIError>) -> Void
    )

    func makeRequest<T: Decodable>(_ request: APIRequest) async throws -> APIResponse<T>

    func makeRequestPublisher<T: Decodable>(_ request: APIRequest) -> AnyPublisher<APIResponse<T>, APIError>
}
