//
//  APIRequestMocks.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

struct MockResource: Codable, Equatable {
    let id: String
}

enum MockError: Error {
    case failed
}

struct MockBody: Encodable {
    let data: MockDataBody

    init(id: String, value: Int) {
        let data = MockDataBody(id: id, value: value)
        self.data = data
    }
}

struct MockDataBody: Encodable {
    let id: String
    let value: Int
}

struct MockAPIRequest: APIRequest {
    typealias Resource = MockResource

    var scheme: String
    var host: String
    var path: String?
    var method: HTTPMethod = .get
    var parameters: Parameters?
    var headers: Headers?
    var body: Encodable?

    init(
        scheme: String = "https",
        host: String = "example.com",
        path: String? = nil,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: Headers? = nil,
        body: Encodable? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }
}
