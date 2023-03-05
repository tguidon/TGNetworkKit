//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import Foundation

public struct URLRequestBuilder: RequestBuilder {

    public init() {
        
    }

    public func build(apiRequest: APIRequest) -> URLRequest? {
        var urlComponents = apiRequest.urlComponents
        /// Add query parameters
        urlComponents.queryItems = apiRequest.params

        guard let url = urlComponents.url else { return nil }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = apiRequest.method.rawValue
        urlRequest.httpBody = apiRequest.data

        /// Add optional header values to request
        apiRequest.headers?.forEach { (key: String, value: String) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }
}
