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
    

    func requestJSONFromDiskCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Cancellable {
        
    }
    
    func requestJSONFromMemoryCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Cancellable {
        
    }
    
    open func responseJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void)) -> Cancellable? {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(_):
            switch target.responseDataSourceType {
            case .server:
                return self.req(target, callbackQueue: callbackQueue, progress: progress) { result in
                    switch result {
                    case .success(let response):
                        let jsonDataResponse = self.serializerJSONDataResponse(response, failsOnEmptyData: failsOnEmptyData)
                        completion(jsonDataResponse)
                    case .failure(let error):
                        completion(SYMoyaNetworkDataResponse(response: nil, result: .failure(error)))
                    }
                }
            case .cache:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: options, callbackQueue: callbackQueue) { result: Result<Response, SYMoyaNetworkError> in
                    
                }
                
                self.retrieve(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, options: options, callbackQueue: callbackQueue, completion: completion)
            case .cacheIfPossible:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, options: options, callbackQueue: callbackQueue) { dataResponse in
                    if dataResponse.result.isSuccess {
                        completion(dataResponse.map({ $0 as Any }))
                    } else {
                        _ = self.requestWithSerializerType(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .cacheAndServer:
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, options: options, callbackQueue: callbackQueue) { dataResponse in
                    if dataResponse.result.isSuccess {
                        completion(dataResponse.map({ $0 as Any }))
                        // 再次发起请求
                        _ = self.requestWithSerializerType(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    } else {
                        _ = self.requestWithSerializerType(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                    }
                }
            case .custom(let customizable):
                let options = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])

                self.retrieve(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, options: options, callbackQueue: callbackQueue) { dataResponse in
                    
                    if dataResponse.result.isSuccess {
                        let isSendRequest = customizable.shouldSendRequest(target, dataResponse: dataResponse)
                        if isSendRequest {
                            // request
                            _ = self.requestWithSerializerType(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                        }
                    } else {
                        if customizable.shouldRequestIfCacheFeatchFailure() {
                            // request
                            _ = self.requestWithSerializerType(.json(Any.self, failsOnEmptyData: failsOnEmptyData), target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                        } else {
                            completion(dataResponse.map({ $0 as Any }))
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
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: false, result: .success(json))
        } catch let error {
            let e = (error as! MoyaError).transformToSYMoyaNetworkError()
            dataRes = SYMoyaNetworkDataResponse(response: response, isDataFromCache: false, result: .failure(e))
        }
        return dataRes
    }

//    func jsonResult(_ response: Moya.Response, failsOnEmptyData: Bool) throws -> Any {
//        switch result {
//        case .success(let response):
//            do {
//                return .success(try response.mapJSON(failsOnEmptyData: failsOnEmptyData))
//            } catch let error {
//                let moyaError = error as! MoyaError
//                return .failure(moyaError.transformToSYMoyaNetworkError())
//            }
//        case .failure(let error):
//            return .failure(error)
//        }
        
//        do {
//            return try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
//        } catch let err {
//
//        }
//
//        return
//    }
}
