//
//  SYMoyaBatchRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/9.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import SwiftyJSON


public enum SYMoyaBatchProviderSessionType {
    // someRequestFail 只要有一个失败，整个批量请求就算失败
    case  ifOneFailureBatchFail
    // 如果其中有一个请求失败，继续执行，返回那个失败的为nil
    case  ifOneFailureBatchContinue
}

public protocol SYBatchMoyaProviderType {
    func requestTargets(_ progress: SYBatchProgressBlock?, completion: ([(SYTargetType, any SYMoyaNetworkDataResponseProtocol)]) -> Void)
}


/// Batch request item object
public struct SYBatchMoyaProvider<TargetType: SYBatchTatgetType>: SYBatchMoyaProviderType {
    private let grop = DispatchGroup()
    private let gropNotifyQueue = DispatchQueue(label: "com.shannonyang.SYMoyaNetwork.SYBatchMoyaProvider.grop.notify.queue.\(UUID().uuidString)")
    
    private let provider: SYMoyaProvider<TargetType>
    public var targetResponsesCompletion: ((_ datas: [(SYTargetType, any SYMoyaNetworkDataResponseProtocol)]) -> Void)?

    public func requestTargets(_ progress: SYBatchProgressBlock?, completion: ([(SYTargetType, any SYMoyaNetworkDataResponseProtocol)]) -> Void) {
        var response = [(SYTargetType, any SYMoyaNetworkDataResponseProtocol)]()
        for targetType in targetTypes {
            grop.enter()
            provider.req(targetType, progress: nil) { result in
                let data = targetType.serializer.serialize(response: result)
                response.append((targetType,data))
                grop.leave()
            }
        }
        grop.notify(queue: gropNotifyQueue) {
            self.targetResponsesCompletion?(response)
            completion(response)
        }
    }
    
    public let targetTypes: [TargetType]
    
    // MARK: - Initallization
    public init(targetTypes: [TargetType]) {
        self.targetTypes = targetTypes
        self.provider = SYMoyaProvider<TargetType>()
    }
}


/// Batch request data response
//public class SYBatchDataResponse<SerializedObject, TargetType: SYBatchTatgetType> {
//    public let targetType: TargetType
//    private let response: SYMoyaNetworkDataResponse<SerializedObject>
//    init(targetType: TargetType,response: SYMoyaNetworkDataResponse<SerializedObject>) {
//        self.targetType = targetType
//        self.response = response
//    }
//}

/// Closure to be executed when progress changes.
public typealias SYBatchProgressBlock = (_ progress: SYBatchProgressResponse) -> Void

public struct SYBatchProgressResponse {
    /// The optional response of the request.
    public let responses: [SYMoyaNetworkDataResponse<Data>]?

    /// An object that conveys ongoing progress for a given request.
    public let progressObject: Progress?

    /// Initializes a `ProgressResponse`.
    public init(progress: Progress? = nil, responses: [SYMoyaNetworkDataResponse<Data>]? = nil) {
        self.progressObject = progress
        self.responses = responses
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
    public func request(_ callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponses: [[(SYTargetType, any SYMoyaNetworkDataResponseProtocol)]]) -> Void) {
        if providers.isEmpty {
            completion(BatchDataResponse(result: .failure(.batchRequestError(reason: .providersIsEmpty))))
            return
        }
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        let batchDataResponse = BatchDataResponse<Target>(result: .success([]))
        let grop = DispatchGroup()
        
        self.providers.forEach { provider in
            queue.async(group: grop) {
                provider.provider.request(provider.targetType, callbackQueue: callbackQueue, progress: progress) { result in
                    switch result {
                    case .success(let response):
                        let re: BatchResult<Target> = BatchResult(batchProvider: provider, response: response)
                        batchDataResponse.value?.append(re)
                    case .failure(let error):
                        batchDataResponse.result = .failure(error.transformToSYMoyaNetworkError())
                        completion(batchDataResponse)
                    }
                }
            }
        }
        let notifyQueue = callbackQueue ?? .main
        grop.notify(queue: notifyQueue) {
            
        }
    }
}
