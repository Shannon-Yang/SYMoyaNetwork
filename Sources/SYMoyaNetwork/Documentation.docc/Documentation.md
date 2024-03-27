# ``SYMoyaNetwork``

Based on the network abstraction of secondary encapsulation of `Moya`. Maintain the same usage method of `Moya`’s `TargetType` implements commonly used data parsing, supporting: `HandyJSON`,`ObjectMapper`, `Codable`, `SwiftyJSON`, Developer there is no need to write boilerplate code for data parsing. You only need to care about what kind of data you want and select the data type. `SYMoyaNetwork` has done all this. `SYMoyaNetwork` also implements network caching, and configure common caching strategies to only implement the desired caching strategy. `Response` will perform cache synchronization according to the policy. Developers no longer need to spend a lot of time doing such work. `SYMoyaNetwork` allows data requests Become simple, less developers write boilerplate code, more time to focus on business.

## Overview

Maybe you will use `Moya` as an abstraction for network requests, like most iOS developers, `Moya` is a great framework that standardizes your data requests and allows you to complete data requests simply enough. `SYMoyaNetwork` is based on `Moya` secondary encapsulation, it does not change the way of using Moya, it is just a further expansion and more friendly encapsulation of `Moya`.

Maybe you would use Moya to write the request like this:

```swift
provider = MoyaProvider<GitHub>()
provider.request(.zen) { result in
    switch result {
    case let .success(moyaResponse):
        let data = moyaResponse.data
        let statusCode = moyaResponse.statusCode
        // do something with the response data or statusCode
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```
When the data request is completed, we need to manually convert `moyaResponse` into the data object we want. For example, when using `ObjectMappe` as the data model, we need to do it every time When returning a response, you need to convert `moyaResponse` into a `BaseMappable` object. Maybe you can encapsulate a unified method to do this, but you still need to manually call some of these conversion methods, which will make the user do this tediously. And tasteless work, so `SYMoyaNetwork` has done such a job, you only need to care about the data you want to get, `SYMoyaNetwork` will give you the data you want to return, For example, when using `ObjectMapper` as the data model, we can obtain the data object like this

```swift
provider = SYMoyaProvider<GitHub>()
/// Note: `BaseMappable `here is the data type in which you implement `BaseMappable`, such as a `Class` or `Struct` or `Other` 
provider.responseObject(.zen) { (response: SYMoyaNetworkDataResponse<BaseMappable>) in
    switch response.result {
    case let .success(mappable):
        // The mappable will be the data you want to get, you can use it directly, you don’t need to do any conversion
    case let .failure(error):
        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```
Now using `SYMoyaNetwork`, you no longer need to worry about how to convert the response into the data you want, you only need to care about the data you want, `SYMoyaNetwork` has already done all this.

`SYMoyaNetwork` provides common data type parsing for a variety of data types, such as: `JSON`, `String`, `Image`, `HandyJSON`, `ObjectMapper`, `Codable`, `SwiftyJSON`, when used You only need to care about the data you want to get, and you don’t need to care about the rest. `SYMoyaNetwork` has already prepared the `Response` of `Moya` Analysis, you only care about your business implementation.

`SYMoyaNetwork` not only converts the `Response` of `Moya`, but more importantly, in `Moya` `SYMoyaNetwork` has helped you with network caching. In most applications, network caching is very important. It can make your App display faster. Data can save data traffic for users. It can be said that it is a very important decision at the network layer. Therefore `SYMoyaNetwork` provides the implementation of commonly used network caching strategies.

`SYMoyaNetwork` supports `Combine`, and also supports `RxSwift`, `ReactiveSwift` and other commonly used responsive frameworks.

`SYMoyaNetwork` also supports chain requests and batch requests. In most business situations, we may have a batch of requests to send, or related chain requests. also provides these Function can be implemented easily and quickly.

## Feature
* Support: `HandyJSON`,`ObjectMapper`, `Codable`, `SwiftyJSON` data parsing, developers only need to care about the data you want to get.
* Extend the `TargetType` of `Moya` and add `timeoutInterval`, `cdnURL`, `allowsCellularAccess`, `cachePolicy` and other attributes.
* Support data caching (disk and memory) and implement data caching strategies.
* Support China Request.
* Support Batch Request.
* Supports `Combine`, and also supports `RxSwift`, `ReactiveSwift` and other commonly used responsive frameworks.
* Supports `Concurrency` asynchronous calls.
* Supports request log output, and request data information is clear at a glance.

## Tip
`SYMoyaNetwork` In order to support different types of data parsing, different types of data parsing are split into different Framework packages. All parsing data packages depend on the core `Core` package. Developers can choose the parsing to use. Type to install, for example: use `RxSwift` to directly install the `SYMoyaObjectMapper` package, if you also need to use `ObjectMapper` as data parsing, then you can install `SYMoyaRxObjectMapper`.

![SYMoyaNetwork](SYMoyaNetwork)

## Topics

### SYMoya
- ``SYMoyaProvider``
- ``SYMoyaProviderSessionResponse``
- ``SYMoyaProviderRequestable``
- ``ResponseSerializer``
- ``ResponseDataSourceType``
- ``SYTargetType``
- ``SYMoyaNetworkResult``

### Batch Request
- ``SYMoyaBatchProviderSession``
- ``SYBatchProgress``
- ``SYMoyaBatchProvider``
- ``SYMoyaBatchProviderReqOperation``
- ``SYBatchMoyaProviderType``
- ``SYBatchProgressBlock``

### Chain Request
- ``SYChainMoyaProviderType``
- ``SYMoyaChainProvider``
- ``SYMoyaChainProviderSession``

### Response 
- ``DecodableResponseSerializer``
- ``SwiftyJSONResponseSerializer``
- ``StringResponseSerializer``
- ``JSONResponseSerializer``
- ``ImageResponseSerializer``
- ``SYDataResponse``
- ``SYDataResponseActor``

### Utility
- ``SYMoyaPublisher``
- ``AsyncOperation``
- ``HTTPStatusCode``
- ``CallbackQueue``
- ``HTTPHeaders``
- ``HTTPVersion``

### Plugin
- ``SYMoyaNetworkLoggerPlugin``
- ``SYMoyaProviderTargetResponseStatePlugin``

### Error
- ``SYMoyaNetworkError``

### Cache
- ``StorageExpiration``
- ``DiskStorage``
- ``MemoryStorage``
- ``CacheSerializer``
- ``NetworkCache``
- ``SYMoyaNetworkOptionsInfo``
- ``NetworkCacheType``
- ``NetworkCacheFromType``

### Config
- ``NetworkConfig``
