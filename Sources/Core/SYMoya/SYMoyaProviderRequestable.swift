//
//  SYMoyaProviderRequestable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/19.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderRequestable

/// An abstraction layer that defines the common request method of Provider.
/// Including requesting data through ``ResponseDataSourceType``, please refer to the ``ResponseDataSourceType`` type description. 
/// If the current ``SYTarget`` implements ``NetworkCacheType`` and returns a ``NetworkCache/cachePath(forKey:)`` type, you can obtain the data in the cache through three methods: ``SYMoyaProviderRequestable/requestFromCache(_:callbackQueue:completion:)``, ``SYMoyaProviderRequestable/requestFromDiskCache(_:callbackQueue:completion:)``,  ``SYMoyaProviderRequestable/requestFromMemoryCache(_:)``.
/// ``SYMoyaProvider`` has implemented ``SYMoyaProviderRequestable`` by default
public protocol SYMoyaProviderRequestable: AnyObject {
    associatedtype Target: SYTargetType
    
    /// Get the data from the cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - callbackQueue: The callback queue on which `completionHandler` is invoked. Default is nil. 
    ///   - completion: A closure which is invoked when the cache operation finishes.
    func requestFromCache(_ target: Target, callbackQueue: DispatchQueue?, completionHandler: @escaping (SYMoyaNetworkResult) -> Void)
    
    /// -func
    func requestFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completionHandler: @escaping (SYMoyaNetworkResult) -> Void)
    
    func requestFromMemoryCache(_ target: Target) -> SYMoyaNetworkResult
    
    @discardableResult
    func request(_ type: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderRequestable Imp
extension SYMoyaProvider: SYMoyaProviderRequestable {
    public func requestFromCache(_ target: Target, callbackQueue: DispatchQueue?, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            completionHandler(result)
        }
    }
    
    public func requestFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            completionHandler(result)
        }
    }
    
    public func requestFromMemoryCache(_ target: Target) -> SYMoyaNetworkResult {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        return result
    }
    
    public func request(_ type: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: Moya.ProgressBlock?, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) -> Moya.Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none,shouldCacheIfNeeded: Bool = true, completionHandler: @escaping (SYMoyaNetworkResult) -> Void) -> Cancellable {
            return self.req(target, callbackQueue: callbackQueue, progress: progress, shouldCacheIfNeeded: shouldCacheIfNeeded) { result in
                completionHandler(result)
            }
        }
        switch target.networkCacheType {
        case .none:
            return req(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
        case .cache:
            switch type {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    completionHandler(result)
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success:
                        completionHandler(result)
                    case .failure:
                        req(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success:
                        completionHandler(result)
                        // make the request again
                        req(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
                    case .failure:
                        req(target, callbackQueue: callbackQueue, progress: progress, completionHandler: completionHandler)
                    }
                }
            case .custom(let customizable):
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success:
                        let isSendRequest = customizable.shouldSendRequest(target, result: result)
                        if isSendRequest {
                            // request
                            let shouldUpdateCache = customizable.shouldUpdateCache(target, result: result)
                            req(target, shouldCacheIfNeeded: shouldUpdateCache, completionHandler: completionHandler)
                        }
                    case .failure(let error):
                        let shouldRequest = customizable.shouldRequestIfCacheFeatchFailure()
                        if shouldRequest {
                            req(target, completionHandler: completionHandler)
                        } else {
                            completionHandler(.failure(error))
                        }
                    }
                }
            }
        }
        return nil
    }
}
