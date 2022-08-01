//
//  SYMoyaProvider.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/20.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// The provider proxy method is called back. When the completion method of moya is called back, the corresponding proxy method will be called back. When the network request is completed, the requestCompleteFilter method will be called back. When the request fails, the requestFailedFilter method will be called back.
public protocol SYMoyaProviderDelegate: NSObjectProtocol {
    
    /// When moya's completion method is called back, the requestCompleteFilter method will be called back when the network request is completed
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - response: The response data object after the request is completed
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, requestCompleteFilter response: Moya.Response)
    
    /// Delegate callback method when data request success
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - response: network request success response
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, requestSuccessFilter response: Moya.Response)
    
    /// Delegate callback method when data request fails
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - error: network request error message
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, requestFailedFilter error: SYMoyaNetworkError)
}

// A request provider class that inherits from MoyaProvider. Requests can only be made through this class.
open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    public weak var delegate: SYMoyaProviderDelegate?
    
    // Mark: Public Properties
    /// The `NetworkCache` used by this manager. It is `NetworkCache.default` by default.
    /// If a cache is specified in `SYMoyaNetwork.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    public let cache: NetworkCache
    
    /// URLCache
    public let urlCache: SYMoyaURLCache
    
    // MARK: - Initallization
    public override init(endpointClosure: @escaping SYMoyaProvider<Target>.EndpointClosure = SYMoyaProvider.syDefaultEndpointMapping, requestClosure: @escaping SYMoyaProvider<Target>.RequestClosure = SYMoyaProvider.defaultRequestMapping, stubClosure: @escaping SYMoyaProvider<Target>.StubClosure = SYMoyaProvider.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<Target>.defaultAlamofireSession(), plugins: [PluginType] = [SYMoyaNetworkLoggerPlugin()], trackInflights: Bool = false) {
        self.cache = NetworkConfig.sharedInstance.networkCache
        self.urlCache = SYMoyaURLCache(urlCache: session.sessionConfiguration.urlCache ?? URLCache.shared)
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    // MARK: - Public
    
    /// Get the SYEndpointResponseState network request status through target
    /// - Parameter target: target type obj
    /// - Returns: The endpoint network request status
    public func endpointResponseState(for target: Target) -> SYEndpointResponseState {
        guard let endpoint = self.endpoint(target) as? SYEndpoint else {
            return .uncompleted
        }
        return endpoint.endpointResponseState
    }
}

//MARK: - Default
public extension SYMoyaProvider {
    
    /// Returns the `Endpoint` converted to a `Target`.
    final class func syDefaultEndpointMapping(for target: Target) -> SYEndpoint {
        var endpoint = SYEndpoint(
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
            if #available(iOS 13.0,watchOS 6.0,tvOS 13.0, macOS 10.15, *) {
                request.allowsExpensiveNetworkAccess = target.allowsExpensiveNetworkAccess
                request.allowsConstrainedNetworkAccess = target.allowsConstrainedNetworkAccess
            }
            if #available(iOS 14.5,tvOS 14.5,macOS 11.3,watchOS 7.4, *) {
                request.assumesHTTP3Capable = target.assumesHTTP3Capable
            }
        } catch let error {
            print("Endpoint failed to get urlRequest, desc: \(error.localizedDescription)")
        }
        
        // set
        switch target.networkCacheType {
        case .urlRequestCache(let urlCacheInfo):
            if target.method == .get {
                if urlCacheInfo.isCanUseCacheControl {
                    endpoint = endpoint.adding(newHTTPHeaderFields: ["Cache-Control" : "no-cache"])
                } else {
                    endpoint = endpoint.adding(newHTTPHeaderFields: ["Pragma" : "no-cache"])
                }
                endpoint = endpoint.adding(newHTTPHeaderFields: [SYMoyaURLCache.refreshCacheKey: SYMoyaURLCache.RefreshCacheValue.refreshCache.rawValue])
            } else {
                print("URLRequestCache only supports get requests, if you want to use other request methods for caching, maybe you can try SYMoyaNetworkCache")
            }
        default:
            break
        }
        
        return endpoint
    }
  
}

//MARK: - Req

extension SYMoyaProvider {
    
    /// Designated request-making method. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Moya.Response, SYMoyaNetworkError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
        
            // callback filter
            DispatchQueue.main.async {
                self.delegate?.provider(self, requestCompleteFilter: response)
            }
            
            // endpoint
            let endpoint = self.endpoint(target) as? SYEndpoint
            
            // assignment request status
            endpoint?.endpointResponseState = .complete
            
            switch result {
            case .success(let response):
                // completion
                completion(.success(response))
                
                // callback filter success
                DispatchQueue.main.async {
                    self.delegate?.provider(self, requestSuccessFilter: response)
                }
                
                // assignment request status
                endpoint?.endpointResponseState = .success
                
                // Cache
                self.cacheIfNeeded(target, response: response)
                
            case .failure(let error):
                let e = error.transformToSYMoyaNetworkError()
                
                // callback filter failure
                DispatchQueue.main.async {
                    self.delegate?.provider(self, requestFailedFilter: e)
                }
                completion(.failure(e))
                
                // assignment request status
                endpoint?.endpointResponseState = .failed
                
                // clear if needed
                switch target.networkCacheType {
                case .urlRequestCache(let urlCacheInfo):
                    if urlCacheInfo.autoClearCache {
                        self.clearCache(target, urlCacheInfo: urlCacheInfo)
                    }
                default:
                    break
                }
            }
        })
    }
}
