//
//  SYDataResponseActor.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/26.
//

import Foundation
import Moya
import SwiftyJSON

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
actor SYDataResponseActor<Target: SYTargetType> {
    private var cancellable: Moya.Cancellable?
    private let provider: SYMoyaProvider<Target>
    
    init(provider: SYMoyaProvider<Target>) {
        self.provider = provider
    }
    
    func responseSwiftyJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, options opt: JSONSerialization.ReadingOptions = [], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        cancellable = provider.responseSwiftyJSON(responseDataSourceType,target: target, options: opt, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
            completion(dataResponse)
        })
    }
    
    func responseJSON(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        cancellable = provider.responseJSON(responseDataSourceType,target: target, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseString(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<String>) -> Void) {
        cancellable = provider.responseString(responseDataSourceType,target: target,atKeyPath: atKeyPath,callbackQueue: callbackQueue,progress: progress, completion: completion)
    }
    
    func responseImage(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        cancellable = provider.responseImage(responseDataSourceType,target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func responseCodableObject<T: Decodable>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseCodableObject(responseDataSourceType,target: target, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
//    func responseObject<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
//        
//    }
//    
//    func responseObjects<T: HandyJSON>(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, designatedPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<[T?]>) -> Void) {
//        
//    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

