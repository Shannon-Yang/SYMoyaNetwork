//
//  SYDataResponseActor+.swift
//  SYMoyaHandyJSON
//
//  Created by Shannon Yang on 2023/6/24.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Foundation
import Moya
import HandyJSON
import SYMoyaNetwork

extension SYDataResponseActor {
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: <#completion description#>
    func responseObject<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: <#completion description#>
    func responseObjects<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
        cancellable = provider.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
