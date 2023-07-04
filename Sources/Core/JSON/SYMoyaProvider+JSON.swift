//
//  SYMoyaProvider+JSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol SYMoyaProviderJSONType: AnyObject {
    associatedtype Target: SYTargetType
    /// Get JSON data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseJSONFromCache(_ target: Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void)
    /// Get JSON data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseJSONFromDiskCache(_ target: Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void)
    /// Get JSON data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: SYMoyaNetworkDataResponse object
    func responseJSONFromMemoryCache(_ target: Target, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<Any>
    /// According to responseDataSourceType, request JSON data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable?
}

//MARK: - SYMoyaProviderJSONType
extension SYMoyaProvider: SYMoyaProviderJSONType {
    public func responseJSONFromCache(_ target: Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkDataResponse<Any>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
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
    
    public func responseJSONFromDiskCache(_ target: Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, completion: @escaping (SYMoyaNetworkDataResponse<Any>) -> Void) {
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
    
    public func responseJSONFromMemoryCache(_ target: Target, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<Any> {
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
    
    public func responseJSON(_ responseDataSourceType: ResponseDataSourceType, target: Target, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: Moya.ProgressBlock?, completion: @escaping (SYMoyaNetworkDataResponse<Any>) -> Void) -> Moya.Cancellable? {
        @discardableResult
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
        case .syMoyaNetworkCache:
            switch responseDataSourceType {
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
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
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
                        var jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
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

//MARK: - JSON Provider
public extension SYMoyaProvider {
    func responseJSONFromCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        self.responseJSONFromCache(target, failsOnEmptyData: true, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseJSONFromDiskCache(_ target: Target, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        self.responseJSONFromDiskCache(target, failsOnEmptyData: true, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseJSONFromMemoryCache(_ target: Target) -> SYMoyaNetworkDataResponse<Any> {
        self.responseJSONFromMemoryCache(target, failsOnEmptyData: true)
    }

    @discardableResult
    func responseJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable? {
        return self.responseJSON(.server, target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) -> Cancellable? {
        return self.responseJSON(responseDataSourceType, target: target, failsOnEmptyData: true, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

//MARK: - Extension
private extension SYMoyaProvider {
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
