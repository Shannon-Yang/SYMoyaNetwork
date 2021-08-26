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
                return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (response) in
                    completion(jsonResult(response: response))
                })
            case .cacheIfPossible:
            // 取缓存
            
            case .cacheAndServer:
                
            case .custom:
            }
        }
    }
    
}


private extension SYMoyaProvider {
    
    func jsonResult(response: Moya.Response, failsOnEmptyData: Bool) -> Result<Any, MoyaError> {
        return response.flatMap { response in
            Result<Any, Error>(catching: {
                try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
            }).mapError { $0 as! MoyaError }
        }
    }
}
