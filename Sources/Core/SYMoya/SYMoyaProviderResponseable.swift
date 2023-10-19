//
//  SYMoyaProviderResponseable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/19.
//

import Foundation
import Moya

public protocol SYMoyaProviderResponseable: AnyObject {
    associatedtype Target: SYTargetType
    
    func requestFromCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (_ result: SYMoyaNetworkResult) -> Void)
    
    func requestFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (_ result: SYMoyaNetworkResult) -> Void)
    
    func requestFromMemoryCache(_ target: Target) -> SYMoyaNetworkResult
    
    @discardableResult
    func request(_ responseDataSourceType: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ result: SYMoyaNetworkResult) -> Void) -> Cancellable?
}

extension SYMoyaProvider: SYMoyaProviderResponseable {
    
    public func requestFromCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkResult) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            completion(result)
        }
    }
    
    public func requestFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkResult) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            completion(result)
        }
    }
    
    public func requestFromMemoryCache(_ target: Target) -> SYMoyaNetworkResult {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        return result
    }
    
    public func request(_ responseDataSourceType: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: Moya.ProgressBlock?, completion: @escaping (SYMoyaNetworkResult) -> Void) -> Moya.Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none,shouldCacheIfNeeded: Bool = true, completion: @escaping (_ result: SYMoyaNetworkResult) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress, shouldCacheIfNeeded: shouldCacheIfNeeded) { result in
                completion(result)
            }
        }
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
        case .syMoyaNetworkCache:
            switch responseDataSourceType {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    completion(result)
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        completion(result)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        completion(result)
                        // make the request again
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .custom(let customizable):
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let isSendRequest = customizable.shouldSendRequest(target, result: result)
                        if isSendRequest {
                            // request
                            let shouldUpdateCache = customizable.shouldUpdateCache(target, result: result)
                            req(target, shouldCacheIfNeeded: shouldUpdateCache, completion: completion)
                        }
                    case .failure(let error):
                        let shouldRequest = customizable.shouldRequestIfCacheFeatchFailure()
                        if shouldRequest {
                            req(target, completion: completion)
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
        return nil
    }
}
