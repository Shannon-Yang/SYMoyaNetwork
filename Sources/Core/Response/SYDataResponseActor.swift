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
    
    
    func responseString(_ responseDataSourceType: ResponseDataSourceType = .server, target: Target, atKeyPath: String? = nil, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<String>) -> Void) {
        cancellable = provider.responseString(responseDataSourceType,target: target,atKeyPath: atKeyPath,callbackQueue: callbackQueue,progress: progress, completion: completion)
    }
    
    
    func cancel() {
        cancellable?.cancel()
    }
}

