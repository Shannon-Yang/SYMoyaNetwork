//
//  SYMoyaProvider+Codable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
#if canImport(Combine)
import Combine
#endif

//MARK: - Codable Provider
public extension SYMoyaProvider {
    
    /// Get Codable data from cache，If there is a cache, it will be obtained in memory first. If there is no cache in the memory, the cache will be read from the disk. If there is no cached data, the completion will callback nil object
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Optional key path at which to parse object.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
    func responseCodableObjectFromCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
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
    
    
//    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//    func responseCodableObjectFromCachePublisher<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> AnyPublisher<SYMoyaNetworkDataResponse<T>, SYMoyaNetworkError> {
//        
//        let publisher = AnyPublisher
//    }
    
//    func responseCodableObjectFromCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) async -> SYMoyaNetworkDataResponse<T> {
//        
//    }
    
    /// Get Codable data from disk cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Optional key path at which to parse object.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - completion: Callback after completion
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
    
    /// Get Codable data from memory cache
    /// - Parameters:
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Optional key path at which to parse object.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    /// - Returns: SYMoyaNetworkDataResponse object
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
    
    /// According to responseDataSourceType, request Codable data. The default responseDataSourceType is .server, which will request data directly from the server. The rules for requesting data refer to: ResponseDataSourceType
    /// - Parameters:
    ///   - responseDataSourceType: Request's responseData source type, implementing different type responseData source type
    ///   - target: The protocol used to define the specifications necessary for a `MoyaProvider`.
    ///   - keyPath: Optional key path at which to parse object.
    ///   - decoder: Default json parsing object
    ///   - failsOnEmptyData: Indicates whether the callback parsing fails when the data is empty, the default is true
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress, the data progress is called back only when a request is sent to obtain server data
    ///   - completion: Callback after completion
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable? {
        
        @discardableResult
        func req<T: Decodable>(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable {
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
        case .syMoyaNetworkCache:
            switch responseDataSourceType {
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
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
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
                        var codableObjectDataResponse: SYMoyaNetworkDataResponse<T> = self.serializerCodableObjectDataResponse(response, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        codableObjectDataResponse.isDataFromCache = true
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: codableObjectDataResponse)
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
    
//    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//    func responsePublisher<T: Decodable>(_ target: Target, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<SYMoyaNetworkDataResponse<T>, SYMoyaNetworkError> {
//        let publisher = self.requestPublisher(target,callbackQueue: callbackQueue)
//        
//    }
}

//MARK: - Extension
private extension SYMoyaProvider {
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

