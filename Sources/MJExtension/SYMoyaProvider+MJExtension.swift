//
//  SYMoyaProvider+MJExtension.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/1/4.
//  Copyright © 2022 Shenzhen JUJUBE Health Technology Co.,Ltd. All rights reserved.
//

import Foundation
import Moya
import MJExtension

//MARK: - MJExtension
public extension SYMoyaProvider {
    
    /// Get MJExtension generic object data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the MJExtension generic object
    func responseObjectFromCache<T: NSObject>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
                objectDataResponse.isDataFromCache = true
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    /// Get MJExtension generic object data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the MJExtension generic object
    func responseObjectFromDiskCache<T: NSObject>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {

        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])

        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
                objectDataResponse.isDataFromCache = true
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    /// Get MJExtension generic object data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseObjectFromMemoryCache<T: NSObject>(_ target: Target) -> SYMoyaNetworkDataResponse<T> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectDataResponse(response)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    /// According to responseDataSourceType, request MJExtension generic object data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: The callback after completion, returns the MJExtension generic object
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseObject<T: NSObject>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        @discardableResult
        func req<T: NSObject>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
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
        case .syMoyaNetworkCache:
            switch responseDataSourceType {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response)
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
    
    /// Get MJExtension generic object array data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the MJExtension generic object array
    func responseObjectsFromCache<T: NSObject>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    /// Get MJExtension generic object array data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the MJExtension generic object array
    func responseObjectsFromDiskCache<T: NSObject>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    /// Get MJExtension generic object array data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseObjectsFromMemoryCache<T: NSObject>(_ target: Target) -> SYMoyaNetworkDataResponse<[T]> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<[T]>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectsDataResponse(response)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    /// According to responseDataSourceType, request MJExtension generic object array data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: The callback after completion, returns the MJExtension generic object array
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseObjects<T: NSObject>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable? {
        
        @discardableResult
        func req<T: NSObject>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response)
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

//MARK: - Extension
public extension SYMoyaProvider {
    
    func serializerObjectDataResponse<T: NSObject>(_ response: Moya.Response) -> SYMoyaNetworkDataResponse<T> {
        let dataRes: SYMoyaNetworkDataResponse<T>
        let object = response.mapObject(T.self)
        if let obj = object {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(obj))
        } else {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(.serializeError(reason: .mjExtensionMap(response: response))))
        }
        return dataRes
    }
    
    func serializerObjectsDataResponse<T: NSObject>(_ response: Moya.Response) -> SYMoyaNetworkDataResponse<[T]> {
        let dataRes: SYMoyaNetworkDataResponse<[T]>
        let objects = response.mapArray(T.self)
        if let objs = objects {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(objs))
        } else {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(.serializeError(reason: .mjExtensionMap(response: response))))
        }
        return dataRes
    }
}
