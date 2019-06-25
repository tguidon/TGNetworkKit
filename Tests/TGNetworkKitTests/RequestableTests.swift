//
//  File.swift
//  
//
//  Created by Taylor Guidon on 6/24/19.
//

import XCTest
@testable import TGNetworkKit

final class RequestableTests: XCTestCase {

    func testCreatableURLRequest() {

        struct Model: Creatable {

            static var baseURL: URL {
                URL(fileURLWithPath: "creatable")
            }

            static var path: String {
                "/path/foo"
            }
        }

        let request = Model.makeRequest()
        XCTAssertEqual(request.httpMethod, Model.httpMethod)
    }

    func testFetchableURLRequest() {

        struct Model: Fetchable {
            var id: Self.ID = "1"

            static var baseURL: URL {
                URL(fileURLWithPath: "creatable")
            }

            static var path: String {
                "/path/foo"
            }
        }
    }

    func testUpdatableURLRequest() {

        struct Model: Updatable {
            var id: Self.ID = "1"

            static var baseURL: URL {
                URL(fileURLWithPath: "creatable")
            }

            static var path: String {
                "/path/foo"
            }
        }
    }

    func testDeletableURLRequest() {

        struct Model: Deletable {
            var id: Self.ID = "1"

            static var baseURL: URL {
                URL(fileURLWithPath: "creatable")
            }

            static var path: String {
                "/path/foo"
            }
        }
    }

    static var requestableTests = [
        ("testCreatableURLRequest", testCreatableURLRequest),
        ("testFetchableURLRequest", testFetchableURLRequest),
        ("testUpdatableURLRequest", testUpdatableURLRequest),
        ("testDeletableURLRequest", testDeletableURLRequest)
    ]
}
