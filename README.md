# 📡 TGNetworkKit 

A Swift package for requesting `Codable` responses. Conform your data type to the `APIRequest` protocol and fire away. Supports `Result` and `Combine` methods.

```swift
public protocol APIRequest: HTTPS {
    associatedtype Resource: Decodable

    /// The scheme subcomponent of the URL
    var scheme: String { get }
    /// The host subcomponent
    var host: String { get }
    /// The path subcomponent
    var path: String? { get }
    /// The HTTP request method
    var method: HTTPMethod { get }
    /// The URL parameters of the request
    var parameters: Parameters? { get }
    /// The request header values
    var headers: Headers? { get }
    /// The data sent as the message body of a request
    var body: Encodable? { get }
}
```

The `HTTPS` protocol defaults the scheme to `"https"`.

## Result

`(Result<T.Resource, APIError>) -> Void)`

Example:

```swift
class NetworkManager {
    let client = APIClient()
    let apiRequest = MockAPIRequest()

    func getData() {
        client.request(apiRequest: apiRequest) { result in
            switch result {
            case .success(let resource):
                print(resource.id)
            case .failure(let error)
                print(error.localizedDescription)
            }
        }
    }
}
```



## Combine

`AnyPublisher<APIResponse<T.Resource>, APIError>`

Example:

```swift
class NetworkManager {
    let client = APIClient()
    let apiRequest = MockAPIRequest()

    let publisher = client.dataTaskPublisher(for: apiRequest)
        .sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
            case .failure:
            }
        }, receiveValue: { apiResponse in
            // handle APIResponse
        })
}
```

