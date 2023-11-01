//
//  SYDataResponseActor+.swift
//  SYMoyaObjectMapper
//
//  Created by Shannon Yang on 2023/6/24.
//

import Foundation
import Moya
import ObjectMapper
import SYMoyaNetwork

extension SYDataResponseActor {
    func responseObject<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectResponseSerializer<T> = .defaultMapperObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseObjects<T: BaseMappable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: ObjectMapperObjectsResponseSerializer<T> = .defaultMapperObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        cancellable = provider.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
