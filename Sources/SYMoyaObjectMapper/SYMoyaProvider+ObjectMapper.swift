//
//  SYMoyaProvider+ObjectMapper.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/17.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

//MARK: - SYMoyaProviderObjectType
extension SYMoyaProvider {
    /// Retrieve data from the cache and parses the retrieved data into an object that implements `BaseMappable`.
    ///
    /// If the type of `cacheFromType` is `.memoryOrDisk`, This method will first retrieve data from the memory cache. If the data is retrieved, `completion` will be called back.
    ///
    ///  If there is no data in the memory cache, the disk will continue to be retrieved, and the `completion` will be called back after the retrieval is completed. refer to ``NetworkCache/retrieveResponse(forKey:options:callbackQueue:completionHandler:)-3l55p``
    ///
    ///  If the type of `cacheFromType` is `.memory`, this method will retrieve data from the memory cache.
    ///
    ///  If the type of `cacheFromType` is `.disk`, this method will retrieve data from the memory cache.
    ///
    ///  When cacheFromType is `.memory` or `.disk`, only one retrieval operation will be performed
    ///  For example: If there is data in the disk cache but not in the memory, and `cacheFromType` is `.memory`, the data will only be retrieved from the memory.
    ///  If there is no data in the memory, you will get `SYMoyaNetworkError.responseNotExisting` and will not continue to retrieve from the disk.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `BaseMappable`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    public func responseObjectFromCache<T: BaseMappable>(_ cacheFromType: NetworkCacheFromType = .memoryOrDisk, target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void){
        self.requestFromCache(cacheFromType,target: target, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    /// A data request method, depending on the data request strategy. and parses the requested data into an object that implements `BaseMappable`
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `BaseMappable`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    public func responseObject<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
        return cancellable
    }
    
    /// Retrieve data from the cache and parses the retrieved data into an object that implements `BaseMappable` array
    ///
    /// If the type of `cacheFromType` is `.memoryOrDisk`, This method will first retrieve data from the memory cache. If the data is retrieved, `completion` will be called back.
    ///
    ///  If there is no data in the memory cache, the disk will continue to be retrieved, and the `completion` will be called back after the retrieval is completed. refer to ``NetworkCache/retrieveResponse(forKey:options:callbackQueue:completionHandler:)-3l55p``
    ///
    ///  If the type of `cacheFromType` is `.memory`, this method will retrieve data from the memory cache.
    ///
    ///  If the type of `cacheFromType` is `.disk`, this method will retrieve data from the memory cache.
    ///
    ///  When cacheFromType is `.memory` or `.disk`, only one retrieval operation will be performed
    ///  For example: If there is data in the disk cache but not in the memory, and `cacheFromType` is `.memory`, the data will only be retrieved from the memory.
    ///  If there is no data in the memory, you will get `SYMoyaNetworkError.responseNotExisting` and will not continue to retrieve from the disk.
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `BaseMappable` array.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - completion: A closure which is invoked when the cache operation finishes. If not specified, the main queue will be used.
    public func responseObjectsFromCache<T: BaseMappable>(_ cacheFromType: NetworkCacheFromType = .memoryOrDisk, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T]>) -> Void){
        self.requestFromCache(cacheFromType,target: target, callbackQueue: callbackQueue) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
    }
    
    /// A data request method, depending on the data request strategy. and parses the requested data into an object that implements `BaseMappable` arry
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `BaseMappable` array.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    public func responseObjects<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable? {
        let cancellable = self.request(type, target: target, callbackQueue: callbackQueue, progress: progress) { result in
            let response = serializer.serialize(result: result)
            completion(response)
        }
        return cancellable
    }
}
