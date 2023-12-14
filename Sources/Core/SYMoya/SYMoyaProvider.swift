//
//  SYMoyaProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/20.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// The provider proxy method is called back. When the completion method of moya is called back, the corresponding proxy method will be called back. When the network request is completed, the requestCompleteFilter method will be called back. When the request fails, the requestFailedFilter method will be called back.
public protocol SYMoyaProviderDelegate: AnyObject {

    /// When moya's completion method is called back, the requestCompleteFilter method will be called back when the network request is completed
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - response: The response data object after the request is completed
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, target: Target?, requestCompleteFilter response: Moya.Response?)
    
    /// Delegate callback method when data request success
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - response: network request success response
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, target: Target?, requestSuccessFilter response: Moya.Response)
    
    /// Delegate callback method when data request fails
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - error: network request error message
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, target: Target?, requestFailedFilter error: SYMoyaNetworkError)
}

// A request provider class that inherits from MoyaProvider. Requests can only be made through this class.
open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    /// Network Request Broker Callback Events
    public weak var delegate: SYMoyaProviderDelegate?
    
    // Mark: Public Properties
    /// The `NetworkCache` used by this manager. It is `NetworkCache.default` by default.
    /// If a cache is specified in `SYMoyaNetwork.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    public let cache: NetworkCache
    
    /// URLCache
    public let urlCache: SYMoyaURLCache
    
    // MARK: - Initallization

    /// Initializes a provider.
    public override init(endpointClosure: @escaping EndpointClosure = SYMoyaProvider<Target>.syDefaultEndpointMapping, requestClosure: @escaping RequestClosure = SYMoyaProvider<Target>.defaultRequestMapping, stubClosure: @escaping StubClosure = SYMoyaProvider<Target>.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<Target>.defaultAlamofireSession(), plugins: [PluginType] = [SYMoyaNetworkLoggerPlugin(),SYMoyaProviderTargetResponseStatePlugin<Target>()], trackInflights: Bool = false) {
        self.cache = NetworkConfig.sharedInstance.networkCache
        self.urlCache = SYMoyaURLCache(urlCache: session.sessionConfiguration.urlCache ?? URLCache.shared)
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    //MARK: - Override
    
    /// Designated request-making method. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    open override func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        return super.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    /// Returns an `Endpoint` based on the token, method, and parameters by invoking the `endpointClosure`.
    open override func endpoint(_ token: Target) -> Endpoint {
        super.endpoint(token)
    }
    
    // swiftlint:disable function_parameter_count
    /// When overriding this method, call `notifyPluginsOfImpendingStub` to prepare your request
    /// and then use the returned `URLRequest` in the `createStubFunction` method.
    /// Note: this was previously in an extension, however it must be in the original class declaration to allow subclasses to override.
    open override func stubRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, completion: @escaping Completion, endpoint: Endpoint, stubBehavior: StubBehavior) -> CancellableToken {
        super.stubRequest(target, request: request, callbackQueue: callbackQueue, completion: completion, endpoint: endpoint, stubBehavior: stubBehavior)
    }
    
    // MARK: - Public
    
    /// Get the request state of the target by passing in a target, and get the request status through the providerResponseStateItems array object in the SYMoyaProviderTargetResponseStatePlugin object
    /// - Parameter target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: Target state
    public func responseState(_ target: Target) -> SYMoyaProviderResponseState {
        guard let item = self.responseStateItem(target) else {
            return .unknown
        }
        return item.state
    }
}

// MARK: - Private
private extension SYMoyaProvider {
    func providerResponseStateItems() -> [SYMoyaProviderTargetResponseStateItem<Target>]? {
        guard let plugin = self.plugins.filter({ $0 is SYMoyaProviderTargetResponseStatePlugin<Target> }).first as? SYMoyaProviderTargetResponseStatePlugin<Target> else {
            return nil
        }
        if plugin.providerResponseStateItems.count == 0 {
            return nil
        }
        return plugin.providerResponseStateItems
    }
    
    func responseStateItem(_ target: Target) -> SYMoyaProviderTargetResponseStateItem<Target>? {
        let providerResponseStateItems = self.providerResponseStateItems()
        let endPoint = self.endpoint(target)
        guard let item = providerResponseStateItems?.filter({ $0.endPoint == endPoint }).first else {
            return nil
        }
        return item
    }
    
    func responseStateItem(_ request: URLRequest?) -> SYMoyaProviderTargetResponseStateItem<Target>? {
        guard let urlRequest = request else {
            return nil
        }
        let providerResponseStateItems = self.providerResponseStateItems()
        guard let item = providerResponseStateItems?.filter({
            if let tryURLRequest = try? $0.endPoint.urlRequest() {
                return tryURLRequest == urlRequest
            }
            return false
        }).first else {
            return nil
        }
        return item
    }
}

//MARK: - Default
public extension SYMoyaProvider {
    
    /// Returns the `Endpoint` converted to a `Target`.
    final class func syDefaultEndpointMapping(for target: Target) -> Endpoint {
        var endpoint = Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers)
        do {
            var request = try endpoint.urlRequest()
            request.timeoutInterval = target.timeoutInterval
            request.mainDocumentURL = target.mainDocumentURL
            request.networkServiceType = target.networkServiceType
            request.allowsCellularAccess = target.allowsCellularAccess
            request.httpShouldHandleCookies = target.httpShouldHandleCookies
            request.httpShouldUsePipelining = target.httpShouldUsePipelining
            request.allowsExpensiveNetworkAccess = target.allowsExpensiveNetworkAccess
            request.allowsConstrainedNetworkAccess = target.allowsConstrainedNetworkAccess
            if #available(iOS 14.5,tvOS 14.5,macOS 11.3,watchOS 7.4, *) {
                request.assumesHTTP3Capable = target.assumesHTTP3Capable
            }
        } catch let error {
            fatalError("Endpoint failed to get urlRequest, desc: \(error.localizedDescription)")
        }
        
        // set url cache
        if case let .urlRequestCache(urlCacheInfo) = target.networkCacheType  {
            if target.method == .get {
                if urlCacheInfo.isCanUseCacheControl {
                    endpoint = (endpoint.adding(newHTTPHeaderFields: ["Cache-Control" : "no-cache"]))
                } else {
                    endpoint = (endpoint.adding(newHTTPHeaderFields: ["Pragma" : "no-cache"]))
                }
                endpoint = (endpoint.adding(newHTTPHeaderFields: [SYMoyaURLCache.refreshCacheKey: SYMoyaURLCache.RefreshCacheValue.refreshCache.rawValue]))
            } else {
                print("URLRequestCache only supports get requests, if you want to use other request methods for caching, maybe you can try SYMoyaNetworkCache")
            }
        }
        return endpoint
    }
}

//MARK: - Req
public extension SYMoyaProvider {
    /// Designated request-making method. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, shouldCacheIfNeeded: Bool = true, completion: @escaping ((_ result: SYMoyaNetworkResult) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            let value = try? result.get()
            
            // state item
            let item = self.responseStateItem(value?.request)
            
            // delegate
            self.delegate?.provider(self, target: item?.target, requestCompleteFilter: value)
            
            switch result {
            case .success(let response):
                // callback filter success
                // delegate
                self.delegate?.provider(self, target: item?.target, requestSuccessFilter: response)
                
                // Cache
                if shouldCacheIfNeeded {
                    self.cacheIfNeeded(target, response: response)
                }
                
                let resultResponse = (response,false)
                // completion
                completion(.success(resultResponse))
                
            case .failure(let error):
                let e = error.transformToSYMoyaNetworkError()
                // callback filter failure
                // delegate
                self.delegate?.provider(self, target: item?.target, requestFailedFilter: e)
                
                // clear if needed
                switch target.networkCacheType {
                case .urlRequestCache(let urlCacheInfo):
                    if urlCacheInfo.autoClearCache {
                        self.clearCache(target, urlCacheInfo: urlCacheInfo)
                    }
                default:
                    break
                }
                
                // completion
                completion(.failure(e))
            }
        })
    }
}
