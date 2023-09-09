//
//  SYMoyaBatchProviderSession.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/9.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum SYMoyaBatchProviderSessionType {
    // someRequestFail 只要有一个失败，整个批量请求就算失败
    case  ifOneFailureBatchFail
    // 如果其中有一个请求失败，继续执行，返回那个失败的为nil
    case  ifOneFailureBatchContinue
}


/// Closure to be executed when progress changes.
public typealias SYBatchProgressBlock = (_ progress: SYBatchProgress) -> Void

public struct SYBatchProgress {
    /// An object that conveys ongoing progress for a given request.
    public let progressObject: Progress?

    /// Initializes a `ProgressResponse`.
    public init(progress: Progress? = nil) {
        self.progressObject = progress
    }

    /// The fraction of the overall work completed by the progress object.
    public var progress: Double {
        if completed {
            return 1.0
        } else if let progressObject = progressObject, progressObject.totalUnitCount > 0 {
            // if the Content-Length is specified we can rely on `fractionCompleted`
            return progressObject.fractionCompleted
        } else {
            // if the Content-Length is not specified, return progress 0.0 until it's completed
            return 0.0
        }
    }

    /// A Boolean value stating whether the request is completed.
    public var completed: Bool { response != nil }
}

//public struct SYBatchDataResponse<Success> {
//    /// The result of response serialization.
//    public var result: Result<[[SYBatchMoyaProviderResponse]]?, SYMoyaNetworkError>
//    
//    /// Returns the associated value of the result if it is a success, `nil` otherwise.
//    public var value: Success? { result.success }
//    
//    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
//    public var error: SYMoyaNetworkError? { result.failure }
//    
//
//    public init(responses: [[SYBatchMoyaProviderResponse]]?,
//                result: Result<Success, Failure>) {
//        self.responses = responses
//        self.result = result
//    }
//}

// Batch request session object, used to session the sending and callback of batch requests
public class SYMoyaBatchProviderSession {
    private let providers: [SYBatchMoyaProviderType]
    private let sessionType: SYMoyaBatchProviderSessionType

    public init(providers: [SYBatchMoyaProviderType], sessionType: SYMoyaBatchProviderSessionType = .ifOneFailureBatchContinue) {
        self.providers = providers
        self.sessionType = sessionType
    }
    
    private let queueName = "com.shannonyang.SYMoyaNetwork.BatchRequest.queue.\(UUID().uuidString)"
    
    /// Make a batch request
    /// - Parameters:
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress
    ///   - completion: The request progress indicates the sum of the request progress of all providers
    public func request(_ callbackQueue: DispatchQueue? = .none, progress: SYBatchProgressBlock? = .none, completion: @escaping (_ result: Result<[[SYBatchMoyaProviderResponse]], SYMoyaNetworkError>) -> Void) {
        if providers.isEmpty {
            completion(.failure(.batchRequestError(reason: .providersIsEmpty)))
            return
        }
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        let grop = DispatchGroup()
        let reponses = [[SYBatchMoyaProviderResponse]]()
        self.providers.forEach { provider in
            queue.async(group: grop) {
                
                provider.requestTargets(<#T##progress: SYBatchProgressBlock?##SYBatchProgressBlock?##(_ progress: SYBatchProgress) -> Void#>, completion: <#T##([SYBatchMoyaProviderResponse]) -> Void#>)
                
                provider.provider.request(provider.targetType, callbackQueue: callbackQueue, progress: progress) { result in
                    switch result {
                    case .success(let response):
                        reponses.append(response)
                    case .failure(let error):
                        completion(.failure(error.transformToSYMoyaNetworkError()))
                    }
                }
                
                
                
            }
        }
        let notifyQueue = callbackQueue ?? .main
        grop.notify(queue: notifyQueue) {
            
        }
    }
}
