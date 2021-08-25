//
//  SYMoyaProvider.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/20.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public enum ResponsePolicy {
    case request
    case cache
    case cacheAndRequest
}

open class SYMoyaProvider<Target: SYTargetType>: Moya.MoyaProvider<Target> {
    
    override init(endpointClosure: @escaping EndpointClosure = SYMoyaProvider.syDefaultEndpointMapping, requestClosure: @escaping RequestClosure = SYMoyaProvider<SYTargetType>.defaultRequestMapping, stubClosure: @escaping SYMoyaProvider<SYTargetType>.StubClosure = MoyaProvider.neverStub, callbackQueue: DispatchQueue? = nil, session: Session = SYMoyaProvider<SYTargetType>.defaultAlamofireSession(), plugins: [PluginType] = [], trackInflights: Bool = false) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    open override func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(let responseDataSourceType):
            switch responseDataSourceType {
            case .server:
                super.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cacheIfPossible:
                // 取缓存
                 
            case .cacheAndServer:
                
            case .custom:
            }
        }
        
        
        super.request(target, callbackQueue: callbackQueue, progress: progress) { result in
            
        }
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
}
