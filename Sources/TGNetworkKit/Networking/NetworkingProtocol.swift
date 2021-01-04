//
//  NetworkingProtocol.swift
//  
//
//  Created by Taylor Guidon on 1/3/21.
//

import Foundation
import Combine

@available(iOS 13.0, *)
/// <#Description#>
protocol NetworkingProtocol {
    var session: URLSession { get }
    var requestBuilder: RequestBuilder { get }
    var requestAdapters: [RequestAdapter] { get }
    var jsonDecoder: JSONDecoder { get }

    /// <#Description#>
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    func execute<T: Decodable>(request: APIRequest, completion: @escaping (Result<T, APIError>) -> Void)
    /// <#Description#>
    /// - Parameter request: <#request description#>
    func buildPublisher<T: Decodable>(for request: APIRequest) -> AnyPublisher<APIResponse<T>, APIError>
}
