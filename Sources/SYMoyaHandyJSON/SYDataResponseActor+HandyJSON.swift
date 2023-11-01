//
//  SYDataResponseActor+.swift
//  SYMoyaHandyJSON
//
//  Created by Shannon Yang on 2023/6/24.
//

import Foundation
import Foundation
import Moya
import HandyJSON
import SYMoyaNetwork

extension SYDataResponseActor {
    func responseObject<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectResponseSerializer<T> = .defaultHandyJSONObjectSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseObject(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseObjects<T: HandyJSON>(_ type: ResponseDataSourceType = .server, target: Target, serializer: HandyJSONObjectsResponseSerializer<T> = .defaultHandyJSONObjectsSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
        cancellable = provider.responseObjects(type,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
