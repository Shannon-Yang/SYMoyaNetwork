//
//  SYMoyaProvider+String.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol SYMoyaProviderStringType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get String data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseStringFromCache(_ target: Target, serializer: StringResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void)
    /// Get String data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void)
    /// Get String data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseStringFromMemoryCache(_ target: Target, serializer: StringResponseSerializer) -> SYMoyaNetworkDataResponse<String>
    /// According to responseDataSourceType, request String data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseString(_ responseDataSourceType: ResponseDataSourceType, target: Target, serializer: StringResponseSerializer, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderStringType
extension SYMoyaProvider: SYMoyaProviderStringType {
    
    public func responseStringFromCache(_ target: Target, serializer: StringResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkDataResponse<String>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    public func responseStringFromDiskCache(_ target: Target, serializer: StringResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    public func responseStringFromMemoryCache(_ target: Target, serializer: StringResponseSerializer) -> SYMoyaNetworkDataResponse<String> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        let response = serializer.serialize(result: result)
        return response
    }
    
    @discardableResult
    public func responseString(_ responseDataSourceType: ResponseDataSourceType, target: Target, serializer: StringResponseSerializer, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                let response = serializer.serialize(result: result)
                completion(response)
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
                    let response = serializer.serialize(result: result)
                    completion(response)
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let response = serializer.serialize(result: result)
                        completion(response)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let response = serializer.serialize(result: result)
                        completion(response)
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
                        let response = serializer.serialize(result: result)
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: response)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<String>(result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}


//MARK: - String Provider
public extension SYMoyaProvider {
    func responseStringFromCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) {
        self.responseStringFromCache(target, serializer: .defaultStringSerializer, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseStringFromDiskCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) {
        self.responseStringFromDiskCache(target, serializer: .defaultStringSerializer, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseStringFromMemoryCache(_ target: Target) -> SYMoyaNetworkDataResponse<String> {
        self.responseStringFromMemoryCache(target,serializer: .defaultStringSerializer)
    }
    
    @discardableResult
    func responseString(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable? {
        return self.responseString(responseDataSourceType, target: target, serializer: .defaultStringSerializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

