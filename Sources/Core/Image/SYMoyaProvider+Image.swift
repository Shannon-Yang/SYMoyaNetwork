//
//  SYMoyaProvider+Image.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol SYMoyaProviderImageType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get Image data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseImageFromCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void)
    /// Get Image data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseImageFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void)
    /// Get Image data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseImageFromMemoryCache(_ target: Target) -> SYMoyaNetworkDataResponse<Image>
    /// According to responseDataSourceType, request Image data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseImage(_ responseDataSourceType: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderJSONType
extension SYMoyaProvider: SYMoyaProviderImageType {
    public func responseImageFromCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            let response = result.serializerImageDataResponse()
            completion(response)
        }
    }
    
    public func responseImageFromDiskCache(_ target: Target, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            let response = result.serializerImageDataResponse()
            completion(response)
        }
    }
    
    public func responseImageFromMemoryCache(_ target: Target) -> SYMoyaNetworkDataResponse<Image> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        let response = result.serializerImageDataResponse()
        return response
    }
    
    @discardableResult
    public func responseImage(_ responseDataSourceType: ResponseDataSourceType, target: Target, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) -> Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                let response = result.serializerImageDataResponse()
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
                    let response = result.serializerImageDataResponse()
                    completion(response)
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let response = result.serializerImageDataResponse()
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
                        let response = result.serializerImageDataResponse()
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
                        let response = result.serializerImageDataResponse()
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: response)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<Image>(result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}

//MARK: - Image Provider
extension SYMoyaProvider {
    func responseImageFromCache(_ target: Target, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        self.responseImageFromCache(target, callbackQueue: .none, completion: completion)
    }
    func responseImageFromDiskCache(_ target: Target, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        self.responseImageFromDiskCache(target, callbackQueue: .none, completion: completion)
    }
    @discardableResult
    public func responseImage(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) -> Cancellable? {
        self.responseImage(responseDataSourceType, target: target, callbackQueue: .none, progress: .none, completion: completion)
    }
}

