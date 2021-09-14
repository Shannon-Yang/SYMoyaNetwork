//
//  SYMoyaProvider+String.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
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
                var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                stringDataResponse.isDataFromCache = true
                completion(stringDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<String>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseStringFromMemoryCache(_ target: Target, atKeyPath: String? = nil) -> SYMoyaNetworkDataResponse<String> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<String>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<String>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    open func responseString(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable? {
        
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                    stringDataResponse.isDataFromCache = false
                    completion(stringDataResponse)
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
                        var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                        stringDataResponse.isDataFromCache = true
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
                        var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                        stringDataResponse.isDataFromCache = true
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
                        var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                        stringDataResponse.isDataFromCache = true
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
                        var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                        stringDataResponse.isDataFromCache = true
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
    
    func serializerStringDataResponse(_ response: Moya.Response, atKeyPath: String? = nil) -> SYMoyaNetworkDataResponse<String> {
        let dataRes: SYMoyaNetworkDataResponse<String>
        do {
            let string = try response.mapString(atKeyPath: atKeyPath)
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(string))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
        }
        return dataRes
    }
}

