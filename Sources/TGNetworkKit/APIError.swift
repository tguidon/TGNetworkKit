//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation

/// Errors returned from URLRequest data tasks
public enum APIError: Error {
    /// The data task returned a non nil error
    case networkingError(Error)

    /// The data task returned an HTTP error in the 500 range
    case serverError(Int, String)

    /// The data task returned an HTTP error in the 400 range
    case requestError(Int, String) // HTTP 4xx

    /// The data task returned an HTTP error in the 300 range
    case redirectionError(Int, String) // HTTP 3xx

    /// The data task returned an HTTP error we do not handle
    case unhandledHTTPStatus(Int, String) // HTTP Unhandled

    /// The data task returned a response that is not an HTTPURLResponse
    case invalidResponse

    /// The client failed to decode the response
    case decodingError(DecodingError)

    /// The client failed to parse the response
    case parseError(Error)
}
