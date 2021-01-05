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
    case serverError(Int, Data?)
    /// The data task returned an HTTP error in the 400 range
    case requestError(Int, Data?)
    /// The data task returned an HTTP error in the 300 range
    case redirectionError(Int, Data?)
    /// The data task returned an HTTP error we do not handle
    case unhandledHTTPStatus(Int, Data?)
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

    /// Init with `Swift.Error` type.
    ///
    /// If the error is a `DecodingError` type, init as our `.decodingError` case
    /// Else attemp to cast as `CKError` and fallback to `.unhandled`
    init(_ error: Swift.Error) {
        switch error {
        case is DecodingError:
            self = .decodingError(error as! DecodingError)
        default:
            self = error as? APIError ?? .unhandled(error.localizedDescription)
        }
    }
}

public extension APIError {
    /// Return an optional status code for errors containing a code property
    var httpStatusCode: Int? {
        switch self {
        case .serverError(let code , _),
             .requestError(let code , _),
             .redirectionError(let code , _),
             .unhandledHTTPStatus(let code , _):
            return code
        default:
            return nil
        }
    }
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
