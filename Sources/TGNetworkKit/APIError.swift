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
    case serverError(Int, String?)
    /// The data task returned an HTTP error in the 400 range
    case requestError(Int, String?)
    /// The data task returned an HTTP error in the 300 range
    case redirectionError(Int, String?)
    /// The data task returned an HTTP error we do not handle
    case unhandledHTTPStatus(Int, String?)
    /// The data task returned a response that is not an HTTPURLResponse
    case invalidResponse
    /// The client failed to decode the response
    case decodingError(DecodingError)
    /// The client failed to parse the response
    case parseError(Error)
    /// Can not create URL from URLComponents
    case failedToBuildURLRequestURL
    /// The API returned nil data
    case dataIsNil
    /// Unhandled error with a String reason
    case unhandled(String)
}

extension APIError: Equatable {

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkingError(let lhsErr), .networkingError(let rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        case (.serverError(let lhsCode, let lhsMessage), .serverError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.requestError(let lhsCode, let lhsMessage), .requestError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.redirectionError(let lhsCode, let lhsMessage), .redirectionError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.unhandledHTTPStatus(let lhsCode, let lhsMessage), .unhandledHTTPStatus(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingError, .decodingError):
            return true
        case (.parseError(let lhsErr), .parseError(let rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        case (.failedToBuildURLRequestURL, .failedToBuildURLRequestURL):
            return true
        case (.dataIsNil, .dataIsNil):
            return true
        case (.unhandled(let lhsMessage), .unhandled(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
