//
//  SYDataResponseActor.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/26.
//

import Foundation
import Moya
import SwiftyJSON

public actor SYDataResponseActor<Target: SYTargetType> {
    public var cancellable: Moya.Cancellable?
    public let provider: SYMoyaProvider<Target>
    
    public init(provider: SYMoyaProvider<Target>) {
        self.provider = provider
    }
    
    public func cancel() {
        cancellable?.cancel()
    }
}

extension SYDataResponseActor {
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        cancellable = provider.responseSwiftyJSON(responseDataSourceType,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
            completion(dataResponse)
        })
    }
    
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        cancellable = provider.responseJSON(responseDataSourceType,target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseString(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<String>) -> Void) {
        cancellable = provider.responseString(responseDataSourceType,target: target,serializer: serializer,callbackQueue: callbackQueue,progress: progress, completion: completion)
    }
    
    func responseImage(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        cancellable = provider.responseImage(responseDataSourceType,target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseCodableObject(responseDataSourceType,target: target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
