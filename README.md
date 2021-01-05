# 📡 TGNetworkKit 

A Swift package for requesting `Codable` responses. Create an instance of `APIRequest`  and fire away. Supports `Result` and `Combine` methods.

```swift
public struct APIRequest {
    public let method: HTTPMethod
    public let scheme: String
    public let host: String
    public let path: String?
    public let headers: Headers?
    public let params: Parameters?
    public let data: Data?

    public init(
        method: HTTPMethod,
        scheme: String = "https",
        host: String,
        path: String? = nil,
        headers: Headers? = nil,
        params: Parameters? = nil,
        data: Data? = nil
    ) {
        self.method = method
        self.scheme = scheme
        self.host = host
        self.path = path
        self.headers = headers
        self.params = params
        self.data = data
    }
}
```



## Result

`(Result<APIResponse<T>, APIError>) -> Void)`

Example:

```swift
class NetworkManager {
    let client = APIClient()
    let apiRequest = APIRequest(...)

    func getData() {
        client.execute(request: apiRequest) { result in
            switch result {
            case .success(let response):
                // handle success
            case .failure(let error)
                // handle error
            }
        }
    }
}
```



## Combine

`AnyPublisher<APIResponse<T>, APIError>`

Example:

```swift
class NetworkManager {
    let client = APIClient()
    let apiRequest = APIRequest(...)

  	typealias TestPublisher = AnyPublisher<APIResponse<Resource>, APIError>
    let publisher: TestPublisher = client.dataTaskPublisher(for: apiRequest)
        .sink(receiveCompletion: { finish in
            switch finish {
            case .finished:
              // handle finish
            case .failure:
              // handle failure
            }
        }, receiveValue: { apiResponse in
            // handle APIResponse
        })
}
```

