//
//  SYMoyaBatchProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//

import Foundation
import Moya

public struct SYBatchDataResponse {
    /// The result of response serialization.
    public var result: Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>
    
    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: [SYBatchMoyaProviderResponse]? { result.success }

    public init(result: Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>) {
        self.result = result
    }
}

public protocol SYBatchMoyaProviderType {
    func requestTargets(_ sessionType: SYMoyaBatchProviderSessionType, completion: @escaping (_ response: SYBatchDataResponse) -> Void)
}

public typealias SYBatchMoyaProviderResponse = (SYTargetType, SYMoyaNetworkResult)

/// Batch request item object
public class SYMoyaBatchProvider<TargetType: SYTargetType>: SYBatchMoyaProviderType {
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "com.shannonyang.SYMoyaNetwork.BatchRequest.operationQueue"
        return operationQueue
    }()
    
    private let provider = SYMoyaProvider<TargetType>()
    private var reqOperations = [SYMoyaBatchProviderReqOperation<TargetType>]()
    
    public var targetResponsesCompletion: ((_ response: SYBatchDataResponse) -> Void)?
    public let targetTypes: [TargetType]
    
    // MARK: - Initallization
    public init(targetTypes: [TargetType]) {
        self.targetTypes = targetTypes
        self.reqOperations = targetTypes.map({ SYMoyaBatchProviderReqOperation(targetType: $0, provider: self.provider) })
    }

    public func requestTargets(_ sessionType: SYMoyaBatchProviderSessionType, completion: @escaping (SYBatchDataResponse) -> Void) {
        var responses = [SYBatchMoyaProviderResponse]()
        var batchResult: Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>?
        for operation in reqOperations {
            operation.completion = { result in
                switch sessionType {
                case .ifOneFailureBatchFail:
                    switch result {
                    case .success(_):
                        responses.append((operation.targetType,result))
                    case .failure(_):
                        self.operationQueue.cancelAllOperations()
                        batchResult = .failure(.batchRequestError(reason: .batchSomeOperationFailure))
                    }
                case .ifOneFailureBatchContinue:
                    responses.append((operation.targetType,result))
                }
            }
            operationQueue.addOperation(operation)
        }
        
        operationQueue.addBarrierBlock {
            let batchDataResponse: SYBatchDataResponse
            if let batchResult {
                batchDataResponse = SYBatchDataResponse(result: batchResult)
            } else {
                batchDataResponse = SYBatchDataResponse(result: .success(responses))
            }
            completion(batchDataResponse)
        }
    }
}
