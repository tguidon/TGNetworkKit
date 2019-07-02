//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import Foundation

/// Protocol that allows us to pass in Codable objects to the API Client
public protocol Requestable: Codable {

    /// Base url of the request
    static var baseURL: URL { get }

    /// Optional path to resource
    static var path: String? { get }
}

public extension Requestable {

    /// Path defaults to nil and is optional to conform to
    static var path: String? {
        return nil
    }

    /// Build the base request based on the path to the resource
    static func makeRequest() -> URLRequest {
        var url = self.baseURL
        if let path = self.path {
            url = url.appendingPathComponent(path)
        }
        let request = URLRequest(url: url)

        return request
    }
}
