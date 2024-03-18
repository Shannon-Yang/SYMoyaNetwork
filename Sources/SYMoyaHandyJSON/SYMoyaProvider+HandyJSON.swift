//
//  SYMoyaProvider+HandyJSON.swift
//  KuaiYin
//
//  Created by Shannon Yang on 2021/9/23.
//  Copyright © 2021 Chengdu Happy Music Technology Co., Ltd. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import SYMoyaNetwork

//MARK: - SYMoyaProviderHandyJSONType
extension SYMoyaProvider {
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - completion: <#completion description#>
    public func responseObjectFromCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - completion: <#completion description#>
    public func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    /// - Returns: <#description#>
    public func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer) -> SYMoyaNetworkDataResponse<T> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }
    
    
    @discardableResult
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    public func responseObject<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
        return cancellable
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - completion: <#completion description#>
    public func responseObjectsFromCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - completion: <#completion description#>
    public func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
        self.requestFromDiskCache(target, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    /// - Returns: <#description#>
    public func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer) -> SYMoyaNetworkDataResponse<[T?]> {
        let result = self.requestFromMemoryCache(target)
        let response = serializer.serialize(result: result)
        return response
    }

    
    @discardableResult
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    public func responseObjects<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T?]>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
        return cancellable
    }
}
