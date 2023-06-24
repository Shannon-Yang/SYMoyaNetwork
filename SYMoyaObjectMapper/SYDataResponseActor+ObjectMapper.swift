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

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SYDataResponseActor {
    
    func responseObject<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseObject(responseDataSourceType,target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseObjects<T: BaseMappable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, keyPath: String? = nil, context: MapContext? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T]>) -> Void) {
        cancellable = provider.responseObjects(responseDataSourceType,target: target, keyPath: keyPath, context: context, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
