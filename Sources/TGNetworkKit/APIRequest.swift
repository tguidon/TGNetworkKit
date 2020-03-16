//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import Foundation

public typealias Parameters = [String: String]
public typealias Headers = [String: String]
public typealias Body = Encodable

public protocol APIRequest: HTTPS {
    associatedtype Resource: Decodable

    /// The scheme subcomponent of the URL
    var scheme: String { get }
    /// The host subcomponent
    var host: String { get }
    /// The path subcomponent
    var path: String? { get }
    /// The HTTP request method
    var method: HTTPMethod { get }
    /// The URL parameters of the request
    var parameters: Parameters? { get }
    /// The request header values
    var headers: Headers? { get }
    /// The data sent as the message body of a request
    var body: Encodable? { get }
}

/// Default `APIRequest` properties
extension APIRequest {

    var path: String? {
        return nil
    }

    var parameters: Parameters? {
        return nil
    }

    var headers: Headers? {
        return nil
    }

    var body: Encodable? {
        return nil
    }
}

extension APIRequest {

    /// Computed `urlComponents` from `APIRequst` properties
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        if let path = self.path {
            components.path = path
        }

        return components
    }
}
