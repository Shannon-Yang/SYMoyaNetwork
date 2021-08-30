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
    
    
    /*
    func requestJSONFromDiskCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Cancellable {
        
    }
    
    func requestJSONFromMemoryCache(_ target: Target,failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none) -> Cancellable {
        
    }
    
    open func requestJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Any, Swift.Error>) -> Void)) -> Cancellable? {
        switch target.networkCacheType {
        case .urlRequestCache,.none:
            break
        case .syMoyaNetworkCache(let networkCacheOptionsInfo):
            
            switch target.responseDataSourceType {
            case .server:
                return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
                    completion(self.jsonResult(result, failsOnEmptyData: failsOnEmptyData))
                })
            case .cache:
                self.retrieve(target, options: <#T##SYMoyaNetworkParsedOptionsInfo#>, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let networkCacheResult):
                        let s = self.jsonResult(result, failsOnEmptyData: failsOnEmptyData)
                    case .failure(let error):
                        
                    }
                    
                    
                   
                    completion()
                }
            case .cacheIfPossible:
                <#code#>
            case .cacheAndServer:
                <#code#>
            case .custom:
                <#code#>
            }
        }
    } */
    
}


private extension SYMoyaProvider {
    
    func jsonResult(_ result: Result<Moya.Response, Swift.Error>, failsOnEmptyData: Bool) -> Result<Any, Swift.Error> {
        return result.flatMap { response in
            Result<Any, Swift.Error>(catching: {
                try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
            }).mapError { $0 as! MoyaError }
        }
    }
}
