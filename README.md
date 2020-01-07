# 📡 TGNetworkKit 

A Swift package for requesting `Codable` responses. Conform your data type to the `APIRequest` protocol. Not all properties are required.

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

Create an instance of the `APIClient` and fire away!

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

