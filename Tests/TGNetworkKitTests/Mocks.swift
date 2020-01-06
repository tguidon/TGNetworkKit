//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/5/20.
//

import XCTest
@testable import TGNetworkKit

struct MockResource: Codable {
    let id: String
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

    var host: String = "example.com"

    var method: HTTPMethod = .get

    var body: Encodable? {
        return MockBody(id: "1", value: 100)
    }

    var parameters: Parameters? = ["foo": "bar", "baz": "bip"]
}
