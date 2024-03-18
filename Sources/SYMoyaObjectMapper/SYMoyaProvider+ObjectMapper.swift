//
//  SYMoyaProvider+ObjectMapper.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/17.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

//MARK: - SYMoyaProviderObjectType
extension SYMoyaProvider {
    
    /// <#Description#>
    /// - Parameters:
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - completion: <#completion description#>
    public func responseObjectFromCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void){
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
    public func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void){
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
    public func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer) -> SYMoyaNetworkDataResponse<T>{
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
    public func responseObject<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
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
    public func responseObjectsFromCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T]>) -> Void){
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
    public func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T]>) -> Void){
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
    public func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer) -> SYMoyaNetworkDataResponse<[T]>{
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
    public func responseObjects<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
        return cancellable
    }
}
