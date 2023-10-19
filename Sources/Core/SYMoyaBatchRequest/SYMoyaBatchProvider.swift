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
    mutating func requestTargets(_ progress: SYBatchProgressBlock?, sessionType: SYMoyaBatchProviderSessionType, completion: @escaping (_ response: SYBatchDataResponse) -> Void)
}

public typealias SYBatchMoyaProviderResponse = (SYTargetType, any SYMoyaNetworkDataResponseProtocol)

/// Batch request item object
public class SYMoyaBatchProvider<TargetType: SYSerializableTatgetType>: SYBatchMoyaProviderType {
    
//    private let grop = DispatchGroup()
//    private let gropNotifyQueue = DispatchQueue(label: "com.shannonyang.SYMoyaNetwork.SYBatchMoyaProvider.grop.notify.queue.\(UUID().uuidString)")
    
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "com.shannonyang.SYMoyaNetwork.BatchRequest.operationQueue"
        return operationQueue
    }()
    
    private let provider = SYMoyaProvider<TargetType>()
    public var targetResponsesCompletion: ((_ response: SYBatchDataResponse) -> Void)?

    public func requestTargets(_ progress: SYBatchProgressBlock?, sessionType: SYMoyaBatchProviderSessionType, completion: @escaping (SYBatchDataResponse) -> Void) {
        var responses = [SYBatchMoyaProviderResponse]()
        
        var batchResult: Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>?
        
        for operation in reqOperations {
            operation.completion = { result in
                switch sessionType {
                case .ifOneFailureBatchFail:
                    switch result {
                    case .success(_):
                        appendResponse()
                    case .failure(_):
                        self.operationQueue.cancelAllOperations()
                        batchResult = .failure(.batchRequestError(reason: .batchSomeOperationFailure))
                    }
                case .ifOneFailureBatchContinue:
                    appendResponse()
                }
                func appendResponse() {
                    let data: any SYMoyaNetworkDataResponseProtocol
                    if let serializer = operation.targetType.serializer {
                        data = serializer.serialize(result: result)
                    } else {
                        data = result.serializerDefaultDataResponse()
                    }
                    responses.append((operation.targetType,data))
                }
            }
            operationQueue.addOperation(operation)
        }
        
//        SYBatchDataResponse.init(result: <#T##Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>#>)
        operationQueue.addBarrierBlock {
            
        }
    }
    
    public let targetTypes: [TargetType]
    private var reqOperations = [SYMoyaBatchProviderReqOperation<TargetType>]()
    
    // MARK: - Initallization
    public init(targetTypes: [TargetType]) {
        self.targetTypes = targetTypes
        self.reqOperations = targetTypes.map({ SYMoyaBatchProviderReqOperation(provider: self.provider, targetType: $0) })
    }
}
