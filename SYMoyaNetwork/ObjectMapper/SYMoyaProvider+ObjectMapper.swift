//
//  SYMoyaProvider+ObjectMapper.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/17.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

extension SYMoyaProvider {
    
    /// 缓存策略，添加到方法传递里面，如果传了当前的缓存策略，那么忽略targettype的缓存策略
    
    open func requestObject<T: BaseMappable>(_ target: Target,keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<T, MoyaError>) -> Void)) -> Cancellable {
        
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            
            let modelResult = result.flatMap { response in
                Result<T, Error>(catching: {
                    if let keyPath = keyPath {
                        return try response.mapObject(T.self, atKeyPath: keyPath, context: context)
                    }
                    return  try response.mapObject(T.self, context: context)
                }).mapError { $0 as! MoyaError }
            }
            completion(modelResult)
        })
    }
    
    open func requestObjects<T: BaseMappable>(_ target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<[T], MoyaError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let modelsResult = result.flatMap { response in
                Result<[T], Error>(catching: {
                    if let keyPath = keyPath {
                        return try response.mapArray(T.self, atKeyPath: keyPath, context: context)
                    }
                    return try response.mapArray(T.self, context: context)
                }).mapError { $0 as! MoyaError }
            }
            completion(modelsResult)
        })
    }
}
