//
//  SYMoyaProvider+String.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaProvider {
    
    func requestStringFromCache() {
        
    }
    
   open func requestString(_ target: Target, keyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<String, MoyaError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let stringResult = result.flatMap { response in
                Result<String, Error>(catching: {
                    try response.mapString(atKeyPath: keyPath)
                }).mapError { $0 as! MoyaError }
            }
            completion(stringResult)
        })
    }
    
}
