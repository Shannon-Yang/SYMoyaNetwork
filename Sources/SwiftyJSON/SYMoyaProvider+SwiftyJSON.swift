//
//  SYMoyaProvider+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

public extension SYMoyaProvider {
    
    func responseSwiftyJSONFromCache(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
                jsonDataResponse.isDataFromCache = true
                completion(jsonDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseSwiftyJSONFromDiskCache(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let response):
                var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
                jsonDataResponse.isDataFromCache = true
                completion(jsonDataResponse)
            case .failure(let error):
                let dataRes = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(response: nil, isDataFromCache: true, result: .failure(error))
                completion(dataRes)
            }
        }
    }
    
    func responseSwiftyJSONFromMemoryCache(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        var dataRes: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
        do {
            let response = try self.retrieveResponseInMemoryCache(target, options: options)
            dataRes = self.serializerSwiftyJSONDataResponse(response, options: opt)
        } catch let error {
            dataRes = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(response: nil, isDataFromCache: true, result: .failure(error as! SYMoyaNetworkError))
        }
        dataRes.isDataFromCache = true
        return dataRes
    }
    
    @discardableResult
    open func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
                    jsonDataResponse.isDataFromCache = false
                    completion(jsonDataResponse)
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
                        var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
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
                        var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
                        jsonDataResponse.isDataFromCache = true
                        completion(jsonDataResponse)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
                        jsonDataResponse.isDataFromCache = true
                        completion(jsonDataResponse)
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
                        var jsonDataResponse = self.serializerSwiftyJSONDataResponse(response, options: opt)
                        jsonDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: jsonDataResponse)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<SwiftyJSON.JSON>(response: nil, isDataFromCache: true, result: .failure(error))
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
    
    func serializerSwiftyJSONDataResponse(_ response: Moya.Response, options opt: JSONSerialization.ReadingOptions = []) -> SYMoyaNetworkDataResponse<SwiftyJSON.JSON> {
        let dataRes: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>
        do {
            let json = try response.mapSwiftyJSON(options: opt)
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .success(json))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, result: .failure(e))
        }
        return dataRes
    }
}

