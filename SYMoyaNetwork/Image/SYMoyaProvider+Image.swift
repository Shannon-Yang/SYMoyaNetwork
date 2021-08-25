//
//  SYMoyaProvider+Image.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/25.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

extension SYMoyaProvider {
    
    func requestImageFromCache() {
        
    }
    
   open func requestImage(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping ((_ result: Result<Image, MoyaError>) -> Void)) -> Cancellable {
        return self.request(target, callbackQueue: callbackQueue, progress: progress, completion: { (result) in
            let imageResult = result.flatMap { response in
                Result<Image, Error>(catching: {
                    try response.mapImage()
                }).mapError { $0 as! MoyaError }
            }
            completion(imageResult)
        })
    }
    
}
