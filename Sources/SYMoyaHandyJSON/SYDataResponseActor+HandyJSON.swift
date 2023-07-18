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

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SYDataResponseActor {
    func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseObject(responseDataSourceType,target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]?>) -> Void) {
        cancellable = provider.responseObjects(responseDataSourceType,target: target, designatedPath: designatedPath, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
