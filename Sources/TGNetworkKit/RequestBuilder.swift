//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/6/20.
//

import Foundation

protocol RequestBuilder {
    func build<T>(apiRequest: T) -> URLRequest? where T: APIRequest
}
