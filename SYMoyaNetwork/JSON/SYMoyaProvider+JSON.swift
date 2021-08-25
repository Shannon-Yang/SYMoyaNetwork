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
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let jsonResult = result.flatMap { response in
                Result<Any, Error>(catching: {
                    try response.mapJSON(failsOnEmptyData: failsOnEmptyData)
                }).mapError { $0 as! MoyaError }
            }
            completion(jsonResult)
        })
    }
    
}
