//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import Foundation

public protocol Requestable: Codable {

    typealias HTTPMethod = String

    static var baseURL: URL { get }

    static var path: String { get }

    static var httpMethod: HTTPMethod { get }
}

public extension Requestable {
    static func makeRequest() -> URLRequest {
        let url = self.baseURL.appendingPathComponent(self.path)
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod

        return request
    }
}

public protocol Identifiable {

    typealias ID = String
    var id: ID { get }
}

public protocol Creatable: Requestable { }
public protocol Fetchable: Requestable, Identifiable { }
public protocol Updatable: Requestable, Identifiable { }
public protocol Deletable: Requestable, Identifiable { }

public extension Creatable {

    static var httpMethod: Self.HTTPMethod {
        return "POST"
    }
}

public extension Fetchable {

    static var httpMethod: Self.HTTPMethod {
        return "GET"
    }
}

public extension Updatable {

    static var httpMethod: Self.HTTPMethod {
        return "PATCH"
    }
}

public extension Deletable {

    static var httpMethod: Self.HTTPMethod {
        return "DELETE"
    }
}
