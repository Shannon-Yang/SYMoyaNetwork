//
//  SYMoyaProvider.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/20.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    // Mark: Public Properties
    /// The `NetworkCache` used by this manager. It is `NetworkCache.default` by default.
    /// If a cache is specified in `SYMoyaNetwork.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    
    public var cache: NetworkCache
    
    
    public override init(endpointClosure: @escaping SYMoyaProvider<Target>.EndpointClosure = SYMoyaProvider.syDefaultEndpointMapping, requestClosure: @escaping SYMoyaProvider<Target>.RequestClosure = SYMoyaProvider.defaultRequestMapping, stubClosure: @escaping SYMoyaProvider<Target>.StubClosure = SYMoyaProvider.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<Target>.defaultAlamofireSession(), plugins: [PluginType] = [], trackInflights: Bool = false) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }

    open override func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        
        
        super.request(target, callbackQueue: callbackQueue, progress: progress) { result in

        }
    }
    
}


public extension SYMoyaProvider {
    
    public enum ProviderSerializerType {
        case image
        case string
        case json
        case codable
        case swiftyjson
        case objectmapper
    }
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
    
    
    func cache(_ target: Target, response: Moya.Response) {
        self.cache.storeToDisk(<#T##data: Data##Data#>, forKey: <#T##String#>, processorIdentifier: <#T##String#>, expiration: <#T##StorageExpiration?#>, callbackQueue: <#T##CallbackQueue#>, completionHandler: <#T##((CacheStoreResult) -> Void)?##((CacheStoreResult) -> Void)?##(CacheStoreResult) -> Void#>)
    }
    
    func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, providerSerializerType: ProviderSerializerType) {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(let responseDataSourceType):
            switch responseDataSourceType {
            case .server:
                switch providerSerializerType {
                case .image:
                    self.requestImage(target, callbackQueue: callbackQueue, progress: progress, completion: <#T##((Result<Image, MoyaError>) -> Void)##((Result<Image, MoyaError>) -> Void)##(Result<Image, MoyaError>) -> Void#>)
                default:
                    <#code#>
                }
                super.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cacheIfPossible:
                // 取缓存

            case .cacheAndServer:

            case .custom:
            }
        }
        
    }
}

