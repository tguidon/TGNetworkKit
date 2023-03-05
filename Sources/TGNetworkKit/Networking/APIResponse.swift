//
//  File.swift
//  
//
//  Created by Taylor Guidon on 3/15/20.
//

import Foundation

public struct APIResponse<T: Decodable> {
    public let value: T
    public let response: HTTPURLResponse
}
