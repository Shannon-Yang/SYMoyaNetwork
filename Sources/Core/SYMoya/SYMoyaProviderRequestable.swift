//
//  SYMoyaProviderRequestable.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/19.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import Moya

//MARK: - SYMoyaProviderRequestable

/// An abstraction layer that defines the common request method of Provider.
///
/// Including requesting data through `ResponseDataSourceType`, refer to the `ResponseDataSourceType` type description. If the current `SYTarget` implements `NetworkCacheType` and returns a `NetworkCache/cachePath(forKey:)` type
///
///  you can retrieve the data in the cache through three methods: ``SYMoyaProviderRequestable/requestFromCache(_:callbackQueue:completion:)``, ``SYMoyaProviderRequestable/requestFromDiskCache(_:callbackQueue:completion:)``,  ``SYMoyaProviderRequestable/requestFromMemoryCache(_:)``.
///
/// `SYMoyaProvider` has implemented `SYMoyaProviderRequestable` by default
public protocol SYMoyaProviderRequestable: AnyObject {
    associatedtype Target: SYTargetType
    
    /// Retrieve data from the disk cache or memory cache
    ///
    /// This method will first retrieve data from the memory cache. If the data is retrieved, `completion` will be called back.
    ///
    ///  If there is no data in the memory cache, the disk will continue to be retrieved, and the `completion` will be called back after the retrieval is completed. refer to ``NetworkCache/retrieveResponse(forKey:options:callbackQueue:completionHandler:)``
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    func requestFromCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkResult) -> Void)
    
    /// Retrieve cached data from disk.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    func requestFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkResult) -> Void)
    
    /// Retrieve cached data from memory cache.
    ///
    /// - Parameter target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    /// - Returns: Return the retrieved data results. Refer to the description of ``SYMoyaNetworkResult``
    func requestFromMemoryCache(_ target: Target) -> SYMoyaNetworkResult
    
    /// A data request method, depending on the data request strategy.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: A description object of the progress of a data request. This progress may be retrieving data from the cache or requesting data from the server,              depending on the `type` value.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func request(_ type: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (SYMoyaNetworkResult) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderRequestable Imp
extension SYMoyaProvider: SYMoyaProviderRequestable {
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
    
    public func request(_ type: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: Moya.ProgressBlock?, completion: @escaping (SYMoyaNetworkResult) -> Void) -> Moya.Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none,shouldCacheIfNeeded: Bool = true, completion: @escaping (SYMoyaNetworkResult) -> Void) -> Cancellable {
            return self.req(target, callbackQueue: callbackQueue, progress: progress, shouldCacheIfNeeded: shouldCacheIfNeeded) { result in
                completion(result)
            }
        }
        switch target.networkCacheType {
        case .none:
            return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
        case .cache:
            switch type {
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
                    case .success:
                        completion(result)
                    case .failure:
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success:
                        completion(result)
                        // make the request again
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    case .failure:
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
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
