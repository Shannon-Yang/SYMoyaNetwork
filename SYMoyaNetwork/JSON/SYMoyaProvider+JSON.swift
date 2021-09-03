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
    
    open func requestJSON(_ target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Any, SYMoyaNetworkError>) -> Void)) -> Cancellable? {
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
                let info = SYMoyaNetworkParsedOptionsInfo([.targetCache(self.cache)])
                self.retrieve(target, options: info, callbackQueue: callbackQueue) { result in
                    switch result {
                    case .success(let networkCacheResult):
                        let s = self.jsonResult(networkCacheResult, failsOnEmptyData: failsOnEmptyData)
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
    }
    
}


private extension SYMoyaProvider {
    
    func jsonResult(_ result: Result<Moya.Response, Swift.Error>, failsOnEmptyData: Bool) -> Result<Any, SYMoyaNetworkError> {

        switch result {
        case .success(let response):
            do {
                return .success(try response.mapJSON(failsOnEmptyData: failsOnEmptyData))
            } catch let error {
                if let moyaError = error as? MoyaError {
                    return .failure(moyaError.transformToSYMoyaNetworkError())
                }
                return .failure(error as! SYMoyaNetworkError)
            }
        case .failure(let error):
            if let moyaError = error as? MoyaError {
                return .failure(moyaError.transformToSYMoyaNetworkError())
            }
            return .failure(error as! SYMoyaNetworkError)
        }

        
//        return result.flatMap { response in
//
//            Result<Any, SYMoyaNetworkError>(catching: {
//
//                do {
//                    return try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
//                } catch let error {
//                    if let moyaError = error as? MoyaError {
//                        return moyaError.transformToSYMoyaNetworkError()
//                    }
//                    return error as! SYMoyaNetworkError
//                }
//            }).mapError {
//                if let moyaError = $0 as? MoyaError {
//                    return moyaError.transformToSYMoyaNetworkError()
//                }
//                return $0 as! SYMoyaNetworkError
//            }
//        }
        
        
    }
}
