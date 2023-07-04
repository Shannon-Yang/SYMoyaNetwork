//
//  SYMoyaProvider+ObjectMapper.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/17.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

public protocol SYMoyaProviderObjectType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get ObjectMapper generic object data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the ObjectMapper generic object
    func responseObjectFromCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void)
    /// Get ObjectMapper generic object data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the ObjectMapper generic object
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void)
    /// Get ObjectMapper generic object data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<T>
    /// According to responseDataSourceType, request ObjectMapper generic object data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: The callback after completion, returns the ObjectMapper generic object
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType, target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable?
    /// Get ObjectMapper generic object array data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the ObjectMapper generic object array
    func responseObjectsFromCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void)
    /// Get ObjectMapper generic object array data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the ObjectMapper generic object array
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void)
    /// Get ObjectMapper generic object array data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<[T]>
    /// According to responseDataSourceType, request ObjectMapper generic object array data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Key-path-taking variants of like-named methods. The default implementation of each parses the key path enough to determine whether or not it has more than one component (key path components are separated by periods). If so, -valueForKey: is invoked with the first key path component as the argument, and the method being invoked is invoked recursively on the result, with the remainder of the key path passed as an argument. If not, the like-named non-key-path-taking method is invoked.
    ///   - context: MapContext is available for developers who wish to pass information around during the mapping process.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: The callback after completion, returns the ObjectMapper generic object array
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType, target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderObjectType
extension SYMoyaProvider: SYMoyaProviderObjectType {
    func responseObjectFromCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void){
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                objectDataResponse.isDataFromCache = true
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void){
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                objectDataResponse.isDataFromCache = true
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<T>{
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    @discardableResult
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType, target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable?{
        @discardableResult
        func req<T: BaseMappable>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                    objectDataResponse.isDataFromCache = false
                    completion(objectDataResponse)
                case .failure(let error):
                    completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                }
            }
        }
        
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
        case .syMoyaNetworkCache(_):
            switch responseDataSourceType {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                        objectDataResponse.isDataFromCache = true
                        completion(objectDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                        objectDataResponse.isDataFromCache = true
                        completion(objectDataResponse)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                        objectDataResponse.isDataFromCache = true
                        completion(objectDataResponse)
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
                    case .success(let response):
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, keyPath: keyPath, context: context)
                        objectDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: objectDataResponse)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func responseObjectsFromCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void){
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void){
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String?, context: MapContext?) -> SYMoyaNetworkDataResponse<[T]>{
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<[T]>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    @discardableResult
    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType, target: Target, keyPath: String?, context: MapContext?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable?{
        @discardableResult
        func req<T: BaseMappable>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                    objectsDataResponse.isDataFromCache = false
                    completion(objectsDataResponse)
                case .failure(let error):
                    completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                }
            }
        }
        
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
        case .syMoyaNetworkCache:
            switch responseDataSourceType {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                        objectsDataResponse.isDataFromCache = true
                        completion(objectsDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                        objectsDataResponse.isDataFromCache = true
                        completion(objectsDataResponse)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                        objectsDataResponse.isDataFromCache = true
                        completion(objectsDataResponse)
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
                    case .success(let response):
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, keyPath: keyPath, context: context)
                        objectsDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: objectsDataResponse)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}

//MARK: - ObjectMapper
public extension SYMoyaProvider {
    
    func responseObjectFromCache<T: BaseMappable>(_ target: Target, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseObjectFromCache(target, keyPath: nil, context: context, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseObjectFromCache<T: BaseMappable>(_ target: Target, keyPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void){
        self.responseObjectFromCache(target, keyPath: keyPath, context: nil, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseObjectFromDiskCache(target, keyPath: nil, context: context, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void){
        self.responseObjectFromDiskCache(target, keyPath: keyPath, context: nil, callbackQueue: callbackQueue, completion: completion)
    }
    
   
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<T> {
        self.responseObjectFromMemoryCache(target, keyPath: nil, context: context)
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String?) -> SYMoyaNetworkDataResponse<T> {
        self.responseObjectFromMemoryCache(target, keyPath: keyPath, context: nil)
    }
    
    @discardableResult
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        return self.responseObject(responseDataSourceType, target: target, keyPath: nil, context: context, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        return self.responseObject(responseDataSourceType, target: target, keyPath: keyPath, context: nil, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
  
    func responseObjectsFromCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        
    }
    
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        
       
    }
   
    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<[T]> {
       
    }
    
    @discardableResult
    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable? {
        
       
    }
}

//MARK: - Extension
public extension SYMoyaProvider {
    
    func serializerObjectDataResponse<T: BaseMappable>(_ response: Moya.Response, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<T> {
        let dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let object: T
            if let keyPath = keyPath {
                object = try response.mapObject(T.self, atKeyPath: keyPath, context: context)
            } else {
                object = try response.mapObject(T.self, context: context)
            }
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(object))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
        }
        return dataRes
    }
    
    func serializerObjectsDataResponse<T: BaseMappable>(_ response: Moya.Response, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<[T]> {
        let dataRes: SYMoyaNetworkDataResponse<[T]>
        do {
            let objects: [T]
            if let keyPath = keyPath {
                objects = try response.mapArray(T.self, atKeyPath: keyPath, context: context)
            } else {
                objects = try response.mapArray(T.self, context: context)
            }
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(objects))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
        }
        return dataRes
    }
}
