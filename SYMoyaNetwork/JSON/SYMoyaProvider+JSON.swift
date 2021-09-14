//
//  SYMoyaProvider+JSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaProvider {
    
    func responseJSONFromDiskCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                jsonDataResponse.isDataFromCache = true
                completion(jsonDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<Any>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseJSONFromMemoryCache(_ target: Target,failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<Any> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<Any>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<Any>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    open func responseJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable? {
        
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                    jsonDataResponse.isDataFromCache = false
                    completion(jsonDataResponse)
                case .failure(let error):
                    completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                }
            }
        }
        
        switch target.networkCacheType {
        case .none, .urlRequestCache:
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
                        var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                        jsonDataResponse.isDataFromCache = true
                        completion(jsonDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                        jsonDataResponse.isDataFromCache = true
                        completion(jsonDataResponse)
                    case .failure(_):
                        _ = req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                        jsonDataResponse.isDataFromCache = true
                        completion(jsonDataResponse)
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
                        var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                        jsonDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: jsonDataResponse)
                        if isSendRequest {
                            // request
                            _ = req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            _ = req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<Any>(response: nil, isDataFromCache: true, result: .failure(error))
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
    
    func serializerJSONDataResponse(_ response: Moya.Response, failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<Any> {
        let dataRes: SYMoyaNetworkDataResponse<Any>
        do {
            let json = try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(json))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
        }
        return dataRes
    }
    
}
