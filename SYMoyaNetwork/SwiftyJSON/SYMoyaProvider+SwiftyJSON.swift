//
//  SYMoyaProvider+SwiftyJSON.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/19.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

extension SYMoyaProvider {
    
    func requestSwiftyJSONFromCache(_ target: Target,completion: @escaping ((_ result: Result<SwiftyJSON.JSON, MoyaError>) -> Void)) {
        
    }
    
   open func requestSwiftyJSON(_ target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<SwiftyJSON.JSON, MoyaError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let swiftyJSONResult = result.flatMap { response in
                Result<SwiftyJSON.JSON, Error>(catching: {
                    
                    
                    
                    try response.mapSwiftyJSON(options: opt)
                }).mapError { $0 as! MoyaError }
            }
            completion(swiftyJSONResult)
        })
    }
    
}
