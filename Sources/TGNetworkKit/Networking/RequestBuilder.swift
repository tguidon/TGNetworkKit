//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/6/20.
//

import Foundation

/// The `RequestBuilder` constructs the `URLRequest` that will be passed in to the `URLSession`
///
/// - Parameters:
///     - request: `URLComponents` are constructed from `Request` object
public protocol RequestBuilder {
    func build(apiRequest: APIRequest) -> URLRequest?
}
