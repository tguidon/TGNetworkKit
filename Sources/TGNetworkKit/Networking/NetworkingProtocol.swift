//
//  NetworkingProtocol.swift
//  
//
//  Created by Taylor Guidon on 1/3/21.
//

import Foundation
import Combine

/// Our API client required properties and method
@available(iOS 13.0, *)
protocol NetworkingProtocol {
    var session: URLSession { get }
    var requestBuilder: RequestBuilder { get }
    var requestAdapters: [RequestAdapter] { get }
    var jsonDecoder: JSONDecoder { get }

    func execute<T: Decodable>(request: APIRequest, completion: @escaping (Result<T, APIError>) -> Void)
    func buildPublisher<T: Decodable>(request: APIRequest) -> AnyPublisher<T, APIError>
}
