//
//  File.swift
//  
//
//  Created by Taylor Guidon on 3/15/20.
//

import Foundation

public struct APIResponse<T: Decodable> {
    let value: T
    let response: URLResponse
}
