//
//  File.swift
//  
//
//  Created by Taylor Guidon on 7/1/19.
//

import Foundation

extension Encodable {

    public var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}
