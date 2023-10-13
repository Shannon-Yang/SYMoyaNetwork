//
//  SYMoyaProvider+JSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol SYMoyaProviderJSONType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get JSON data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseJSONFromCache(_ target: Target, serializer: JSONResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void)
    /// Get JSON data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseJSONFromDiskCache(_ target: Target, serializer: JSONResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void)
    /// Get JSON data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseJSONFromMemoryCache(_ target: Target, serializer: JSONResponseSerializer) -> SYMoyaNetworkDataResponse<Any>
    /// According to responseDataSourceType, request JSON data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, serializer: JSONResponseSerializer, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderJSONType
extension SYMoyaProvider: SYMoyaProviderJSONType {
    public func responseJSONFromCache(_ target: Target, serializer: JSONResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkDataResponse<Any>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    public func responseJSONFromDiskCache(_ target: Target, serializer: JSONResponseSerializer, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkDataResponse<Any>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    public func responseJSONFromMemoryCache(_ target: Target, serializer: JSONResponseSerializer) -> SYMoyaNetworkDataResponse<Any> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        let response = serializer.serialize(result: result)
        return response
    }
    
    public func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, serializer: JSONResponseSerializer, callbackQueue: DispatchQueue?, progress: Moya.ProgressBlock?, completion: @escaping (SYMoyaNetworkDataResponse<Any>) -> Void) -> Moya.Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                let response = serializer.serialize(result: result)
                completion(response)
            }
        }
        
        switch target.networkCacheType {
        case .none, .urlRequestCache:
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
                            let re = SYMoyaNetworkDataResponse<Any>(result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}

//MARK: - JSON Provider
public extension SYMoyaProvider {
    func responseJSONFromCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        self.responseJSONFromCache(target, serializer: .defaultJSONSerializer, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseJSONFromDiskCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        self.responseJSONFromDiskCache(target, serializer: .defaultJSONSerializer, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseJSONFromMemoryCache(_ target: Target) -> SYMoyaNetworkDataResponse<Any> {
        self.responseJSONFromMemoryCache(target, serializer: .defaultJSONSerializer)
    }

    @discardableResult
    func responseJSON(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable? {
        return self.responseJSON(.server, target: target, serializer: .defaultJSONSerializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable? {
        return self.responseJSON(responseDataSourceType, target: target, serializer: .defaultJSONSerializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

