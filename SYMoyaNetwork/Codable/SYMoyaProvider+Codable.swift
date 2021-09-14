//
//  SYMoyaProvider+Codable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaProvider {
    
    func responseCodableObjectFromDiskCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                codableObjectDataResponse.isDataFromCache = true
                completion(codableObjectDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<T>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseCodableObjectFromMemoryCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<T> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<T>(response: nil, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    open func responseCodableObject<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        
        func req<T: Decodable>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                    codableObjectDataResponse.isDataFromCache = false
                    completion(codableObjectDataResponse)
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
                        var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        codableObjectDataResponse.isDataFromCache = true
                        completion(codableObjectDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        codableObjectDataResponse.isDataFromCache = true
                        completion(codableObjectDataResponse)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        codableObjectDataResponse.isDataFromCache = true
                        completion(codableObjectDataResponse)
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
                        var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        codableObjectDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: codableObjectDataResponse)
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
}

extension SYMoyaProvider {
    
    func serializerCodableObjectDataResponse<T: Decodable>(_ response: Moya.Response, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<T> {
        let dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let codableObject: T = try response.mapCodableObject(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(codableObject))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
        }
        return dataRes
    }
}

