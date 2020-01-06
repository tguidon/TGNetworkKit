//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import Foundation

struct URLRequestBuilder {

    func build<T: APIRequest>(apiRequest: T) throws -> URLRequest {
        var urlComponents = apiRequest.urlComponents
        /// Add query parameters
        urlComponents.queryItems = apiRequest.parameters?.map{ URLQueryItem(name: $0.key, value: $0.value) }

        /// Make URL request
        guard let url = urlComponents.url else {
            throw APIError.canNotCastURLFromURLComponents
        }
        var urlRequest = URLRequest(url: url)
        /// Set passed in HTTP method
        urlRequest.httpMethod = apiRequest.method.rawValue
        /// If an encodable body is passed in, encode to `httpBody`
        if let body = apiRequest.body {
            urlRequest.httpBody = body.data
        }

        return urlRequest
    }
}
