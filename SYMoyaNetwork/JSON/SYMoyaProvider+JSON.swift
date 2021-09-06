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
    
    open func requestJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void)) -> Cancellable? {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(let networkCacheOptionsInfo):

            switch target.responseDataSourceType {
            case .server:
                return self.requestJSON(target) { jsonResult in
                    let dataResponse = SYMoyaNetworkDataResponse(response: <#T##Response?#>, isDataFromCache: <#T##Bool#>, result: <#T##Result<_, SYMoyaNetworkError>#>)
                    completion(false,jsonResult)
                }
            case .cache:
                let info = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: info, callbackQueue: callbackQueue) { result in
                    let jsonResult = self.jsonResult(result, failsOnEmptyData: failsOnEmptyData)
                    completion(true, jsonResult)
                }
            case .cacheIfPossible:
                let info = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: info, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let jsonResult = self.jsonResult(result, failsOnEmptyData: failsOnEmptyData)
                        completion(true, jsonResult)
                    case .failure(_):
                        self.requestJSON(target) { jsonResult in
                            completion(false,jsonResult)
                        }
                    }
                }
            case .cacheAndServer:
                let info = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: info, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(_):
                        let jsonResult = self.jsonResult(result, failsOnEmptyData: failsOnEmptyData)
                        completion(true, jsonResult)
                        // 再次发起请求
                        self.requestJSON(target) { jsonResult in
                            completion(false,jsonResult)
                        }
                    case .failure(_):
                        self.requestJSON(target) { jsonResult in
                            completion(false,jsonResult)
                        }
                    }
                }
            case .custom(let customizable):
                let info = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                
                self.retrieve(target, options: info, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let response):
                        let isSendRequest = customizable.shouldSendRequest(target, cacheResponse: response)
                        if isSendRequest {
                            // 发起请求
                            self.requestJSON(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress) {  (jsonResponse, jsonResult) in
                                let isUpdateCache = customizable.shouldUpdateCache(target, response: jsonResponse)
                                
                                completion(false,jsonResult)
                            }
                        }
                        
                        
                        let jsonResult = self.jsonResult(result, failsOnEmptyData: failsOnEmptyData)
                        completion(true, jsonResult)
                        
                    case .failure(let error):
                        if customizable.shouldRequestIfCacheNotExist() {
                            self.requestJSON(target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress) {  (_, jsonResult) in
                                completion(false,jsonResult)
                            }

                        } else {
                            completion(false, .failure(error))
                        }
                    }
                }
            }
        }
        return nil
    }
}


private extension SYMoyaProvider {
    
    func jsonResult(_ result: Result<Moya.Response, SYMoyaNetworkError>, failsOnEmptyData: Bool) -> Result<Any, SYMoyaNetworkError> {
        switch result {
        case .success(let response):
            do {
                return .success(try response.mapJSON(failsOnEmptyData: failsOnEmptyData))
            } catch let error {
                let moyaError = error as! MoyaError
                return .failure(moyaError.transformToSYMoyaNetworkError())
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func requestJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ response: Moya.Response?, _ result: Result<Any, SYMoyaNetworkError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(let response):
                let jsonResult = self.jsonResult(result.mapError({ return $0.transformToSYMoyaNetworkError() }), failsOnEmptyData: failsOnEmptyData)
                
                switch jsonResult {
                case .success(let json):
                    // completion
                    completion(response,.success(json))
                case .failure(let error):
                    completion(response,.failure(error))
                }
                
                // cache
                self.cache(target, response: response)
                
                // callback filter
                DispatchQueue.main.async {
                    self.requestCompleteFilter(response)
                }
            case .failure(let error):
                let e = error.transformToSYMoyaNetworkError()
                // callback filter
                DispatchQueue.main.async {
                    self.requestFailedFilter(e)
                }
                completion(nil,.failure(e))
            }
        })
    }
}
