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
    
    func responseStringFromDiskCache(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                let stringDataResponse = self.serializerStringDataResponse(response, isDataFromCache: true, atKeyPath: atKeyPath)
                completion(stringDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<String>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseStringFromMemoryCache(_ target: Target, atKeyPath: String? = nil) -> SYMoyaNetworkDataResponse<String> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let dataRes: SYMoyaNetworkDataResponse<String>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerStringDataResponse(response, isDataFromCache: true, atKeyPath: atKeyPath)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<String>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        return dataRes
    }
    
    open func CodableObject<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Cancellable? {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(_):
            func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable {
                self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                    switch result {
                    case .success(let response):
                        let stringDataResponse = self.serializerStringDataResponse(response, isDataFromCache: false, atKeyPath: atKeyPath)
                        completion(stringDataResponse)
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
                        let stringDataResponse = self.serializerStringDataResponse(response, isDataFromCache: true, atKeyPath: atKeyPath)
                        completion(stringDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let stringDataResponse = self.serializerStringDataResponse(response, isDataFromCache: true, atKeyPath: atKeyPath)
                        completion(stringDataResponse)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let stringDataResponse = self.serializerStringDataResponse(response, isDataFromCache: true, atKeyPath: atKeyPath)
                        completion(stringDataResponse)
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
                        let stringDataResponse = self.serializerStringDataResponse(response, isDataFromCache: true, atKeyPath: atKeyPath)
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: stringDataResponse)
                        if isSendRequest {
                            // request
                            _ = req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            _ = req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<String>(response: nil, isDataFromCache: true, result: .failure(error))
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
    
    func serializerCodableObjectDataResponse<T: Decodable>(_ response: Moya.Response, isDataFromCache: Bool, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<T> {
        let dataRes: SYMoyaNetworkDataResponse<T>
        do {
            let codableObject = try response.mapCodableObject<T>(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: isDataFromCache, result: .success(codableObject))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: isDataFromCache, result: .failure(e))
        }
        return dataRes
    }
}


extension SYMoyaProvider {
    
    func requestCodableObjectFromCache<T: Decodable>(_ target: Target, completion: @escaping ((_ result: Result<T, MoyaError>) -> Void)) {
        
    }
    
    open func requestCodableObject<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<T, MoyaError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let codableResult = result.flatMap { response in
                Result<T, Error>(catching: {
                    try response.mapCodableObject(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                }).mapError { $0 as! MoyaError }
            }
            completion(codableResult)
        })
    }
}
