//
//  Encodable+Extensions.swift
//  
//
//  Created by Taylor Guidon on 7/1/19.
//

import Foundation

extension Encodable {

    public var asData: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(self)
    }
}
