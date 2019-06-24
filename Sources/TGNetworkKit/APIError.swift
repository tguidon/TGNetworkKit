//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation

public enum APIError: Error {
    case networkingError(Error)
    case serverError(Int, String) // HTTP 5xx
    case requestError(Int, String) // HTTP 4xx
    case redirectionError(Int, String) // HTTP 3xx
    case unhandledHTTPStatus(Int, String) // HTTP Unhandled
    case invalidResponse
    case decodingError(DecodingError)
    case parseError(Error)
}
