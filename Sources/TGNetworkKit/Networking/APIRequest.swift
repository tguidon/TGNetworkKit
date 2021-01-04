//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import Foundation

public typealias Headers = [String: String]
public typealias Parameters = [URLQueryItem]

public struct APIRequest {
    public let method: HTTPMethod
    public let scheme: String
    public let host: String
    public let path: String?
    public let headers: Headers?
    public let params: Parameters?
    public let data: Data?

    public init(
        method: HTTPMethod,
        scheme: String = "https",
        host: String,
        path: String? = nil,
        headers: Headers? = nil,
        params: Parameters? = nil,
        data: Data? = nil
    ) {
        self.method = method
        self.scheme = scheme
        self.host = host
        self.path = path
        self.headers = headers
        self.params = params
        self.data = data
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
