//
//  File.swift
//  
//
//  Created by Taylor Guidon on 3/15/20.
//

import Foundation

public extension Error {

    /// Attemps to cast Error to APIError
    /// If the value can not be cast, return an unhandled APIError type
    var asAPIError: APIError {
        guard let error = self as? APIError else {
            return APIError.unhandled(self.localizedDescription)
        }

        return error
    }
}
