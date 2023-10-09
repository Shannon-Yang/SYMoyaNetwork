//
//  SYMoyaProvider+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

public protocol SYMoyaProviderSwiftyJSONType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get SwiftyJSON data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseSwiftyJSONFromCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void)
    /// Get SwiftyJSON data from disk cache
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseSwiftyJSONFromDiskCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void)
    /// Get SwiftyJSON data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseSwiftyJSONFromMemoryCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
    /// According to responseDataSourceType, request SwiftyJSON data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderSwiftyJSONType
extension SYMoyaProvider: SYMoyaProviderSwiftyJSONType {
    public func responseSwiftyJSONFromCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
            completion(response)
        }
    }
    
    public func responseSwiftyJSONFromDiskCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
            completion(response)
        }
    }
    
    public func responseSwiftyJSONFromMemoryCache(_ target: Target, options opt: JSONSerialization.ReadingOptions, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
        return response
    }
    
    @discardableResult
    public func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, options opt: JSONSerialization.ReadingOptions, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: false)
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
                    let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
                    completion(response)
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
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
                        let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
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
                        let response = result.serializerSwiftyJSON(ptions: opt, isDataFromCache: true)
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: response)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(response: nil, isDataFromCache: true, result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}

//MARK: - SwiftyJSON Provider
extension SYMoyaProvider {
    func responseSwiftyJSONFromCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        self.responseSwiftyJSONFromCache(target, options: [], callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseSwiftyJSONFromDiskCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        self.responseSwiftyJSONFromDiskCache(target, options: [], callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseSwiftyJSONFromMemoryCache(_ target: Target, failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        self.responseSwiftyJSONFromMemoryCache(target, options: [], failsOnEmptyData: failsOnEmptyData)
    }
    
    @discardableResult
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable? {
        return self.responseSwiftyJSON(responseDataSourceType, target: target, options: [], callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
