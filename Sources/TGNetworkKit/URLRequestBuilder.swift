//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import Foundation

struct URLRequestBuilder: RequestBuilder {

    func build<T>(apiRequest: T) throws -> URLRequest where T: APIRequest {
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
            urlRequest.httpBody = body.asData
        }
        /// Add optional header values to request
        apiRequest.headers?.forEach { (key: String, value: String) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }
}
