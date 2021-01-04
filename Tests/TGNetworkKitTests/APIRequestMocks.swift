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

enum MockError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let reason):
            return "\(reason)"
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .failed(let reason):
            return "\(reason)"
        }
    }
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

extension APIRequest {

    static func buildMock(
        method: HTTPMethod = .get,
        scheme: String = "https",
        host: String = "example.com",
        path: String? = nil,
        headers: Headers? = nil,
        params: Parameters? = nil,
        data: Data? = nil
    ) -> APIRequest {
        return APIRequest(
            method: method,
            scheme: scheme,
            host: host,
            path: path,
            headers: headers,
            params: params,
            data: data
        )
    }
}
