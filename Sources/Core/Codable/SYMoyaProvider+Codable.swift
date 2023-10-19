//
//  SYMoyaProvider+Codable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

//MARK: - SYMoyaProviderCodableType
extension SYMoyaProvider {
    public func responseCodableObjectFromCache<T: Decodable>(_ target: Target, serializer: CodableResponseSerializer<T> = ResponseSerializer.defaultCodableSerializer, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ response: SYMoyaNetworkDataResponse<T>) -> Void) {
        
        self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
            let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
            completion(response)
        }
        
        self.requestFromCache(target, callbackQueue: callbackQueue) { result in
            let codable = 
        }
        
    }
    
    public func responseCodableObjectFromDiskCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        self.retrieveResponseInDiskCache(target, options: options, callbackQueue: callbackQueue) { result in
            let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
            completion(response)
        }
    }
    
    public func responseCodableObjectFromMemoryCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool) -> SYMoyaNetworkDataResponse<T> {
        let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
        let result = self.retrieveResponseInMemoryCache(target, options: options)
        let response = result.serializerCodableObjectDataResponse(type: T.self, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
        return response
    }
    
    @discardableResult
    public func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType, target: Target, atKeyPath keyPath: String?, using decoder: JSONDecoder, failsOnEmptyData: Bool, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable? {
        @discardableResult
        func req(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable {
            self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                completion(response)
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
                    let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                    completion(response)
                }
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        completion(response)
                    case .failure(_):
                        req(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        completion(response)
                        
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
                    case .success(_):
                        let response: SYMoyaNetworkDataResponse<T> = result.serializerCodableObjectDataResponse(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: response)
                        if isSendRequest {
                            // request
                            req(target, completion: completion)
                        }
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            req(target, completion: completion)
                        } else {
                            let re = SYMoyaNetworkDataResponse<T>(result: .failure(error))
                            completion(re)
                        }
                    }
                }
            }
        }
        return nil
    }
}

//MARK: - Codable Provider
public extension SYMoyaProvider {
    func responseCodableObjectFromCache<T: Decodable>(_ target: Target, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseCodableObjectFromCache(target, atKeyPath: nil, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: completion)
    }
    
    func responseCodableObjectFromCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseCodableObjectFromCache(target, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: completion)
    }
    
    
    func responseCodableObjectFromDiskCache<T: Decodable>(_ target: Target, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        self.responseCodableObjectFromDiskCache(target, atKeyPath: nil, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, completion: completion)
    }
    

    func responseCodableObjectFromMemoryCache<T: Decodable>(_ target: Target, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<T> {
        self.responseCodableObjectFromMemoryCache(target, atKeyPath: nil, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
    
    func responseCodableObjectFromMemoryCache<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, failsOnEmptyData: Bool = true) -> SYMoyaNetworkDataResponse<T> {
        self.responseCodableObjectFromMemoryCache(target, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: failsOnEmptyData)
    }
    
    @discardableResult
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable? {
        return self.responseCodableObject(responseDataSourceType, target: target, atKeyPath: nil, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath keyPath: String? = nil, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) -> Moya.Cancellable? {
        return self.responseCodableObject(responseDataSourceType, target: target, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}

