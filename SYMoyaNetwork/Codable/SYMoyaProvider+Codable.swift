//
//  SYMoyaProvider+Codable.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaProvider {
    
    func requestCodableObjectFromCache<T: Decodable>(_ target: Target, completion: @escaping ((_ result: Result<T, MoyaError>) -> Void)) {
        
    }
    
    open func requestCodableObject<T: Decodable>(_ target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<T, MoyaError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let codableResult = result.flatMap { response in
                Result<T, Error>(catching: {
                    try response.mapCodableObject(atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
                }).mapError { $0 as! MoyaError }
            }
            completion(codableResult)
        })
    }
}
