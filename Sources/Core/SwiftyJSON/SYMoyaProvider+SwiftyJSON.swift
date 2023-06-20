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

//MARK: - SwiftyJSON Provider
public extension SYMoyaProvider {
    
    /// Get SwiftyJSON data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
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
    
    /// Get SwiftyJSON data from disk cache
    ///
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
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
    
    /// Get SwiftyJSON data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    /// - Returns: SYMoyaNetworkDataResponse object
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
    
    /// According to responseDataSourceType, request SwiftyJSON data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - opt: A class for converting JSON to Foundation objects and converting Foundation objects to JSON.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) -> Cancellable? {
        
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

//MARK: - Extension
private extension SYMoyaProvider {
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

