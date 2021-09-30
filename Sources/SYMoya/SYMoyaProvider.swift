//
//  SYMoyaProvider.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/20.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

protocol SYMoyaProviderDelegate: NSObjectProtocol {
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, requestCompleteFilter response: Moya.Response)
    func provider<Target: SYTargetType>(_ provider: SYMoyaProvider<Target>, requestFailedFilter error: SYMoyaNetworkError)
}

open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    weak var delegate: SYMoyaProviderDelegate?
    
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
}

//MARK: - Default
public extension SYMoyaProvider {
    
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
            if #available(iOS 13.0, *) {
                request.allowsExpensiveNetworkAccess = target.allowsExpensiveNetworkAccess
                request.allowsConstrainedNetworkAccess = target.allowsConstrainedNetworkAccess
            }
            if #available(iOS 14.5, *) {
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
    
    @discardableResult
    func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Moya.Response, SYMoyaNetworkError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(let response):
                // completion
                completion(.success(response))
                
                // callback filter
                DispatchQueue.main.async {
                    self.delegate?.provider(self, requestCompleteFilter: response)
                }
                
                // Cache
                self.cacheIfNeeded(target, response: response)
                
            case .failure(let error):
                let e = error.transformToSYMoyaNetworkError()
                // callback filter
                DispatchQueue.main.async {
                    self.delegate?.provider(self, requestFailedFilter: e)
                }
                completion(.failure(e))
                
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
