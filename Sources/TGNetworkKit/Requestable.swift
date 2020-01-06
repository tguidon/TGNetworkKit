//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import Foundation

/// Protocol that allows us to pass in Codable objects to the API Client
public protocol Requestable: Codable {

    /// URL Scheme
    static var scheme: String { get }

    /// Base url of the request
    static var host: String { get }

    /// Optional path to resource
    static var path: String? { get }
}

public extension Requestable {

    /// Default to `https`
    static var scheme: String {
        return "https"
    }

    /// Path defaults to nil and is optional to conform to
    static var path: String? {
        return nil
    }

    /// Build the base request based on the path to the resource
    static func buildURLComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        if let path = self.path {
            components.path = path
        }

        return components
    }
}
