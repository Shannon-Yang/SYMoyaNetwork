//
//  SYMoyaProvider+String.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - String Provider
public extension SYMoyaProvider {
    
    /// Get String data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseStringFromCache(_ target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
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
    
    /// Get String data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
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
    
    /// Get String data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    /// - Returns: SYMoyaNetworkDataResponse object
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
    
    
    /// According to responseDataSourceType, request String data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - atKeyPath: Optional key path at which to parse string.
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseString(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<String>) -> Void) -> Cancellable? {
        @discardableResult
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
        case .syMoyaNetworkCache:
            switch responseDataSourceType {
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
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
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
                        var stringDataResponse = self.serializerStringDataResponse(response, atKeyPath: atKeyPath)
                        stringDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: stringDataResponse)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
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

//MARK: - Extension
public extension SYMoyaProvider {
    
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

