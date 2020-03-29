//
//  File.swift
//  
//
//  Created by Taylor Guidon on 3/15/20.
//

import Foundation

public protocol HTTPS {
    var scheme: String { get }
}

public extension HTTPS {
    var scheme: String {
        return "https"
    }
}
