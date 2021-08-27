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
    
    
    
    func requestJSONFromCache() {
        
    }
    
    open func requestJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Any, MoyaError>) -> Void)) -> Cancellable {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(let responseDataSourceType):
            switch responseDataSourceType {
            case .server:
                return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
                    
                    
                    
                    
                    completion(self.jsonResult(result, failsOnEmptyData: failsOnEmptyData))
                })
            case .cache:
                self.cache.retrieveResponse(forKey: <#T##String#>, options: <#T##SYMoyaNetworkOptionsInfo?#>, callbackQueue: <#T##CallbackQueue#>, completionHandler: <#T##((Result<NetworkCacheResult, SYMoyaNetworkError>) -> Void)?##((Result<NetworkCacheResult, SYMoyaNetworkError>) -> Void)?##(Result<NetworkCacheResult, SYMoyaNetworkError>) -> Void#>)
            case .cacheIfPossible:
            // 取缓存
               
            case .cacheAndServer:
                 
            case .custom:
            }
        }
    }
    
}


private extension SYMoyaProvider {
    
    func jsonResult(_ result: Result<Moya.Response, MoyaError>, failsOnEmptyData: Bool) -> Result<Any, MoyaError> {
        return result.flatMap { response in
            Result<Any, Error>(catching: {
                try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
            }).mapError { $0 as! MoyaError }
        }
    }
}
