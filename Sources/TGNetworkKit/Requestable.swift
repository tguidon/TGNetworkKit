//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import Foundation

public protocol Requestable: Codable {

    static var baseURL: URL { get }

    static var path: String? { get }
}

public extension Requestable {

    static var path: String? {
        return nil
    }

    static func makeRequest() -> URLRequest {
        var url = self.baseURL
        if let path = self.path {
            url = url.appendingPathComponent(path)
        }
        let request = URLRequest(url: url)

        return request
    }
}

public protocol Identifiable: Requestable {

    typealias ID = String
    var id: ID { get }
}
