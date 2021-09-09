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

extension SYMoyaProvider {
    
    func responseObjectFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                let objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, isDataFromCache: true, keyPath: keyPath, context: context)
                completion(objectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<T> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        return dataRes
    }
    
    
    open func responseObject<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        
        func req<T: BaseMappable>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    let objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
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
            switch target.responseDataSourceType {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
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
                        let objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        completion(objectDataResponse)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        completion(objectDataResponse)
                        // 再次发起请求
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .custom(let customizable):
                
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let objectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerObjectDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: objectDataResponse)
                        if isSendRequest {
                            // request
                            _ = req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            _ = req(target, completion: completion)
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
    
    
    func responseObjectsFromDiskCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                let objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, isDataFromCache: true, keyPath: keyPath, context: context)
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectsFromMemoryCache<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<[T]> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let dataRes: SYMoyaNetworkDataResponse<[T]>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectsDataResponse(response, isDataFromCache: true, keyPath: keyPath, context: context)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<[T]>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        return dataRes
    }
    

    open func responseObjects<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable? {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(_):
            func req<T: BaseMappable>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) -> Cancellable {
                self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                    switch result {
                    case .success(let response):
                        let objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        completion(objectsDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            }
            
            switch target.responseDataSourceType {
            case .server:
                return req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
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
                        let objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        completion(objectsDataResponse)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        completion(objectsDataResponse)
                        // 再次发起请求
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .custom(let customizable):
                
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let objectsDataResponse: SYMoyaNetworkDataResponse<[T]> = self.serializerObjectsDataResponse(response, isDataFromCache: false, keyPath: keyPath, context: context)
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: objectsDataResponse)
                        if isSendRequest {
                            // request
                            _ = req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            _ = req(target, completion: completion)
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

extension SYMoyaProvider {
    
    func serializerObjectDataResponse<T: BaseMappable>(_ response: Moya.Response, isDataFromCache: Bool, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<T> {
        let dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let object: T
            if let keyPath = keyPath {
                object = try response.mapObject(T.self, atKeyPath: keyPath, context: context)
            } else {
                object = try response.mapObject(T.self, context: context)
            }
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: isDataFromCache, result: .success(object))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: isDataFromCache, result: .failure(e))
        }
        return dataRes
    }
    
    func serializerObjectsDataResponse<T: BaseMappable>(_ response: Moya.Response, isDataFromCache: Bool, keyPath: String? = nil, context: MapContext? = nil) -> SYMoyaNetworkDataResponse<[T]> {
        let dataRes: SYMoyaNetworkDataResponse<[T]>
        do {
            let objects: [T]
            if let keyPath = keyPath {
                objects = try response.mapArray(T.self, atKeyPath: keyPath, context: context)
            } else {
                objects = try response.mapArray(T.self, context: context)
            }
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: isDataFromCache, result: .success(objects))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: isDataFromCache, result: .failure(e))
        }
        return dataRes
    }
}
