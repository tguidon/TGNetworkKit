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

    func execute<T: Decodable>(
        request: APIRequest,
        completion: @escaping (Result<APIResponse<T>, APIError>) -> Void
    )

    func buildPublisher<T: Decodable>(
        for request: APIRequest
    ) -> AnyPublisher<APIResponse<T>, APIError>
}
