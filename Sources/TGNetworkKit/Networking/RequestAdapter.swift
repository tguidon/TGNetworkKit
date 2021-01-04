//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/3/21.
//

import Foundation

/// Adapt a `URLRequest` with additional information
public protocol RequestAdapter {
    func adapt(_ urlRequest: inout URLRequest)
}
