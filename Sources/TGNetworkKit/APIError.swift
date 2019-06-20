//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/20/19.
//

import Foundation

public enum APIError: Error {
    case networkingError(Error)
    case serverError // HTTP 5xx
    case requestError(Int, String) // HTTP 4xx
    case invalidResponse
    case decodingError(DecodingError)
}
