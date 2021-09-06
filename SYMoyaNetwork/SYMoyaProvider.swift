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

public enum ProviderSerializerType {
    case data
    case image
    case string(keyPath: String?)
    case json(failsOnEmptyData: Bool = true)
    case codable(keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true)
    case swiftyjson(opt: JSONSerialization.ReadingOptions = [])
    case objectmapper(keyPath: String? = nil, context: MapContext? = nil)
}

open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    // Mark: Public Properties
    /// The `NetworkCache` used by this manager. It is `NetworkCache.default` by default.
    /// If a cache is specified in `SYMoyaNetwork.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    
    public let cache: NetworkCache
    
    
    public override init(endpointClosure: @escaping SYMoyaProvider<Target>.EndpointClosure = SYMoyaProvider.syDefaultEndpointMapping, requestClosure: @escaping SYMoyaProvider<Target>.RequestClosure = SYMoyaProvider.defaultRequestMapping, stubClosure: @escaping SYMoyaProvider<Target>.StubClosure = SYMoyaProvider.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<Target>.defaultAlamofireSession(), plugins: [PluginType] = [], trackInflights: Bool = false) {
        self.cache = NetworkCache.default
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }

//    open override func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
//
//
//        super.request(target, callbackQueue: callbackQueue, progress: progress) { result in
//
//        }
//    }
    
    ///  Called on the main thread after request succeeded.
    
    func requestCompleteFilter(_ response: Moya.Response) { }
    
    ///  Called on the main thread when request failed.
    
    func requestFailedFilter(_ error: SYMoyaNetworkError) { }
    
}

public extension SYMoyaProvider {
    
    final class func syDefaultEndpointMapping(for target: Target) -> Endpoint {
        let endpoint = Endpoint(
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
        case .urlRequestCache(let cachePolicy):
            break
        default:
            break
        }
    }
    
    func retrieve(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completionHandler: ((Result<Moya.Response, SYMoyaNetworkError>) -> Void)?) {
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
                    completionHandler?(.success(response))
                case .disk(let response):
                    completionHandler?(.success(response))
                case .none:
                    // cache Not Existing
                    completionHandler?(.failure(.cacheError(reason: .responseNotExisting(key: key))))
                }
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func retrieveResponseInMemoryCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo) -> Moya.Response? {
        let key = self.generateCacheKey(target)
        return self.cache.retrieveResponseInMemoryCache(forKey: key, options: options)
    }
    
    func retrieveResponseInDiskCache(_ target: Target, options: SYMoyaNetworkParsedOptionsInfo, callbackQueue: DispatchQueue? = .none, completionHandler: @escaping (Result<Moya.Response?, SYMoyaNetworkError>) -> Void) {
        let key = self.generateCacheKey(target)
        var queue = CallbackQueue.untouch
        if let cQueue = callbackQueue {
            queue = CallbackQueue.dispatch(cQueue)
        }
        self.cache.retrieveResponseInDiskCache(forKey: key, options: options, callbackQueue: queue, completionHandler: completionHandler)
    }
}
