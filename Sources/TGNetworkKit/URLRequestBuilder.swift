//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import Foundation

// URL parameteres
public typealias Parameters = [String: String]

class URLRequestBuilder {

    var urlComponents: URLComponents
    var method: HTTPMethod = .get
    var body: Encodable?
    var urlParameters: Parameters?

    init(urlComponents: URLComponents, method: HTTPMethod, body: Encodable?, urlParameters: Parameters?) {
        self.urlComponents = urlComponents
        self.method = method
        self.body = body
        self.urlParameters = urlParameters
    }

    func build() throws -> URLRequest {
        /// Add query parameters
        urlComponents.queryItems = urlParameters?.map{ URLQueryItem(name: $0.key, value: $0.value) }

        /// Make URL request
        guard let url = urlComponents.url else {
            throw APIError.canNotCastURLFromURLComponents
        }
        var request = URLRequest(url: url)
        /// Set passed in HTTP method
        request.httpMethod = method.rawValue
        /// If an encodable body is passed in, encode to `httpBody`
        if let body = body {
            request.httpBody = body.data
        }

        return request
    }
}
