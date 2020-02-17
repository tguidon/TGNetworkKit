//
//  File.swift
//  
//
//  Created by Taylor Guidon on 1/29/20.
//

import Foundation

class URLProtocolMock: URLProtocol {

    // Maps data to URLs for testing
    static var dataURLs = [URL?: Data]()
    static var responseURLs = [URL?: URLResponse]()
    static var errorURLs = [URL?: Error]()

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let url = request.url {
            if let data = URLProtocolMock.dataURLs[url] {
                // Found Data for the given url, return that to the client
                print(String(data: data, encoding: .utf8)!)
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocol(self, didReceive: self.makeURLResponse(url: url), cacheStoragePolicy: .allowed)
            } else if let urlResponse = URLProtocolMock.responseURLs[url] {
                // Found URLResponse for the given url, return that to the client
                self.client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .allowed)
            } else if let error = URLProtocolMock.errorURLs[url] {
                // Found Error for the given url, return that to the client
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }

        // Finished with the request
        self.client?.urlProtocolDidFinishLoading(self)
    }

    private func makeURLResponse(url: URL, statusCode: Int = 200) -> URLResponse {
        return HTTPURLResponse(
            url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil
        )!
    }

    override func stopLoading() { }
}
