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

public extension SYMoyaProvider {
    
    func responseObjectFromCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
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

    func responseObjectFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {

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

    func responseObjectFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil) -> SYMoyaNetworkDataResponse<T> {
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
    open func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
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
                        // 再次发起请求
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
    
    func responseObjectsFromCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T?]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectsFromDiskCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
                objectsDataResponse.isDataFromCache = true
                completion(objectsDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<[T?]>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseObjectsFromMemoryCache<T: HandyJSON>(_ target: Target, designatedPath: String? = nil) -> SYMoyaNetworkDataResponse<[T?]> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<[T?]>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<[T?]>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    
    @discardableResult
    open func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) -> Cancellable? {
        
        @discardableResult
        func req<T: HandyJSON>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
                        objectsDataResponse.isDataFromCache = true
                        completion(objectsDataResponse)
                        // 再次发起请求
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
                        var objectsDataResponse: SYMoyaNetworkDataResponse<[T?]> = self.serializerObjectsDataResponse(response, designatedPath: designatedPath)
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
                            let re = SYMoyaNetworkDataResponse<[T?]>(response: nil, isDataFromCache: true, result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}

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
    
    func serializerObjectsDataResponse<T: HandyJSON>(_ response: Moya.Response, designatedPath: String? = nil) -> SYMoyaNetworkDataResponse<[T?]> {
        let dataRes: SYMoyaNetworkDataResponse<[T?]>
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
