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


open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    // Mark: Public Properties
    /// The `NetworkCache` used by this manager. It is `NetworkCache.default` by default.
    /// If a cache is specified in `SYMoyaNetwork.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    
    public let cache: NetworkCache
    
    public let urlCache: SYMoyaURLCache
    
    public override init(endpointClosure: @escaping SYMoyaProvider<Target>.EndpointClosure = SYMoyaProvider.syDefaultEndpointMapping, requestClosure: @escaping SYMoyaProvider<Target>.RequestClosure = SYMoyaProvider.defaultRequestMapping, stubClosure: @escaping SYMoyaProvider<Target>.StubClosure = SYMoyaProvider.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<Target>.defaultAlamofireSession(), plugins: [PluginType] = [], trackInflights: Bool = false) {
        self.cache = NetworkCache.default
        self.urlCache = SYMoyaURLCache(urlCache: session.sessionConfiguration.urlCache ?? URLCache.shared)
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    ///  Called on the main thread after request succeeded.
    
    func requestCompleteFilter(_ response: Moya.Response) { }
    
    ///  Called on the main thread when request failed.
    
    func requestFailedFilter(_ error: SYMoyaNetworkError) { }
    
    
    class func clearAll() {
        
    }
    
}

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
    
    func generateCacheKey(_ target: Target) -> String {
        let urlString = URL(target: target).absoluteString
        
        var parametersString: String?
        if let httpBody = try? self.endpoint(target).urlRequest().httpBody {
            parametersString = String(decoding: httpBody, as: UTF8.self)
        }
        
        let method = target.method.rawValue
        
        var cacheKey: String = NetworkCacheType.defaultCacheKey
        switch target.networkCacheType {
        case .syMoyaNetworkCache(let info):
            cacheKey = info.cacheKey
        default:
            break
        }
        
        var key: String = "\(cacheKey)+\(urlString)+\(method)"
        if let string = parametersString {
            key.append("+\(string)")
        }
        return key.md5()
    }
    
    
    func cache(_ target: Target, response: Moya.Response, completionHandler: ((CacheStoreResult) -> Void)? = nil) {
        switch target.networkCacheType {
        case .syMoyaNetworkCache(let networkCacheOptionsInfo):
            
            if let cacheTime = networkCacheOptionsInfo.cacheTime {
                
                guard cacheTime > 0 else {
                    return
                }
                
                if response.data.isEmpty {
                    return
                }
                
                if target.requestBaseURL().absoluteString.isEmpty {
                    return
                }
                
                if target.path.isEmpty {
                    return
                }
                
                if URL(target: target).absoluteString.isEmpty {
                    return
                }
                
                let key = self.generateCacheKey(target)
                
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.cache.store(response, forKey: key, options: options, toDisk: false, callbackQueue: .untouch, completionHandler: completionHandler)
            }
        case .urlRequestCache(let urlCacheInfo):
            self.urlCache(target, response: response, urlCacheInfo: urlCacheInfo)
        case .none:
            break
        }
    }
    
    func retrieve(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completion: (_ result: Result<Moya.Response, SYMoyaNetworkError>) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.untouch
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponse(forKey: key, options: options, callbackQueue: queue) { result in
            switch result {
            case .success(let networkCacheResult):
                switch networkCacheResult {
                case .memory(let response):
                    completion(.success(response))
                case .disk(let response):
                    completion(.success(response))
                case .none:
                    // cache Not Existing
                    completion(.failure(.cacheError(reason: .responseNotExisting(key: key))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func retrieveResponseInMemoryCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo) throws -> Moya.Response {
        let key = self.generateCacheKey(target)
        if let data = self.cache.retrieveResponseInMemoryCache(forKey: key, options: options) {
            return data
        }
        throw SYMoyaNetworkError.cacheError(reason: .responseNotExisting(key: key))
    }
    
    func retrieveResponseInDiskCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completionHandler: @escaping (Result<Moya.Response, SYMoyaNetworkError>) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.untouch
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponseInDiskCache(forKey: key, options: options, callbackQueue: queue, completionHandler: completionHandler)
    }
    
    func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Moya.Response, SYMoyaNetworkError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(let response):
                // completion
                completion(.success(response))
                
                // callback filter
                DispatchQueue.main.async {
                    self.requestCompleteFilter(response)
                }
                
                // Cache
                self.cacheIfNeeded(target, response: response)
                
            case .failure(let error):
                let e = error.transformToSYMoyaNetworkError()
                // callback filter
                DispatchQueue.main.async {
                    self.requestFailedFilter(e)
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
    
    
    func cacheIfNeeded(_ target: Target, response: Moya.Response) {
        // Cache
        switch target.networkCacheType {
        case .urlRequestCache(_):
            self.cache(target, response: response)
        case .syMoyaNetworkCache(_):
            switch target.responseDataSourceType {
            case .cacheIfPossible, .cacheAndServer:
                // cache
                self.cache(target, response: response)
            case .custom(let customizable):
                let dataResponse = SYMoyaNetworkDataResponse(response: response, isDataFromCache: false, result: .success(response))
                let isUpdateCache = customizable.shouldUpdateCache(target, dataResponse: dataResponse)
                if isUpdateCache {
                    self.cache(target, response: response)
                }
            default:
                break
            }
        case .none:
            break
        }
    }
}
