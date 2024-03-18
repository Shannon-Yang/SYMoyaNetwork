//
//  SYDataResponseActor+.swift
//  SYMoyaObjectMapper
//
//  Created by Shannon Yang on 2023/6/24.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

extension SYDataResponseActor {
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseObject<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - target: <#target description#>
    ///   - serializer: <#serializer description#>
    ///   - callbackQueue: <#callbackQueue description#>
    ///   - progress: <#progress description#>
    ///   - completion: <#completion description#>
    func responseObjects<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        cancellable = provider.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
