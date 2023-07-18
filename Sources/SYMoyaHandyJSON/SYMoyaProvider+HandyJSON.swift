//
//  SYMoyaProvider+HandyJSON.swift
//  KuaiYin
//
//  Created by ShannonYang on 2021/9/23.
//  Copyright © 2021 Chengdu Happy Music Technology Co., Ltd. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import SYMoyaNetwork

public protocol SYMoyaProviderHandyJSONType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get HandyJSON generic object data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the HandyJSON generic object
    func responseObjectFromCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void)
    /// Get HandyJSON generic object data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the HandyJSON generic object
    func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void)
    /// Get HandyJSON generic object data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String?) -> SYMoyaNetworkDataResponse<T>
    /// According to responseDataSourceType, request HandyJSON generic object data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: The callback after completion, returns the HandyJSON generic object
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable?
    /// Get HandyJSON generic object array data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the HandyJSON generic object array
    func responseObjectsFromCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void)
    /// Get HandyJSON generic object array data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the HandyJSON generic object array
    func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void)
    /// Get HandyJSON generic object array data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: The callback after completion, returns the HandyJSON generic object array
    func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String?) -> SYMoyaNetworkDataResponse<[T?]?>
    /// According to responseDataSourceType, request HandyJSON generic object array data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - designatedPath: is a string like `result.data.orderInfo`, which each element split by `.` represents key of each layer, or nil
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: The callback after completion, returns the HandyJSON generic object array
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) -> Cancellable?
}


//MARK: - SYMoyaProviderHandyJSONType
extension SYMoyaProvider: SYMoyaProviderHandyJSONType {
    public func responseObjectFromCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
                objectDataResponse.isDataFromCache = true
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    
    public func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
                objectDataResponse.isDataFromCache = true
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    
    public func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String?) -> SYMoyaNetworkDataResponse<T> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    
    @discardableResult
    public func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        @discardableResult
        func req<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
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
                        var objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, designatedPath: designatedPath)
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
    
    
    public func responseObjectsFromCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T?]?>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    
    public func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T?]?>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    
    public func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String?) -> SYMoyaNetworkDataResponse<[T?]?> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<[T?]?>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<[T?]?>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    
    
    @discardableResult
    public func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType, target: Target, designatedPath: String?, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) -> Cancellable? {
        @discardableResult
        func req<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]?> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                            let re = SYMoyaNetworkDataResponse<[T?]?>(response: nil, isDataFromCache: true, result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}


//MARK: - HandyJSON Provider
public extension SYMoyaProvider {
    
    func responseObjectFromCache<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseObjectFromCache(target, designatedPath: nil, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseObjectFromDiskCache(target, designatedPath: nil, callbackQueue: callbackQueue, completion: completion)
    }
    
    
    func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target) -> SYMoyaNetworkDataResponse<T> {
        self.responseObjectFromMemoryCache(target, designatedPath: nil)
    }
    
    
    @discardableResult
    func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        return self.responseObject(responseDataSourceType, target: target, designatedPath: nil, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    
    func responseObjectsFromCache<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) {
        self.responseObjectsFromCache(target, designatedPath: nil, callbackQueue: callbackQueue, completion: completion)
    }
    
    
    func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) {
        self.responseObjectsFromDiskCache(target, designatedPath: nil, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Target) -> SYMoyaNetworkDataResponse<[T?]?> {
        self.responseObjectsFromMemoryCache(target, designatedPath: nil)
    }
    
    @discardableResult
    func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) -> Cancellable? {
        return self.responseObjects(responseDataSourceType, target: target, designatedPath: nil, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

//MARK: - Extension

public extension SYMoyaProvider {

    func serializerObjectDataResponse<T: HandyJSON>(_ response: Moya.Response, designatedPath: String? = nil) -> SYMoyaNetworkDataResponse<T> {
        let dataRes: SYMoyaNetworkDataResponse<T>
        let object: T?
        if let designatedPath = designatedPath {
            object = response.mapObject(T.self, designatedPath: designatedPath)
        } else {
            object = response.mapObject(T.self)
        }
        if let obj = object {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(obj))
        } else {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: response))))
        }
        return dataRes
    }
    
    func serializerObjectsDataResponse<T: HandyJSON>(_ response: Moya.Response, designatedPath: String? = nil) -> SYMoyaNetworkDataResponse<[T?]?> {
        let dataRes: SYMoyaNetworkDataResponse<[T?]?>
        let objects: [T?]?
        if let designatedPath = designatedPath {
            objects = response.mapArray(T.self, designatedPath: designatedPath)
        } else {
            objects = response.mapArray(T.self)
        }
        
        if let objs = objects {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(objs))
        } else {
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(.serializeError(reason: .handlyJSONObjectMap(response: response))))
        }
        return dataRes
    }
}
