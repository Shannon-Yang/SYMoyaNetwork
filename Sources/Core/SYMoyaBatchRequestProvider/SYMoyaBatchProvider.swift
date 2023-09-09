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
    
    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: SYMoyaNetworkError? { result.failure }
    

    public init(result: Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>) {
        self.result = result
    }
}


public protocol SYBatchMoyaProviderType {
    mutating func requestTargets(_ progress: SYBatchProgressBlock?, sessionType: SYMoyaBatchProviderSessionType, completion: (_ response: SYBatchDataResponse) -> Void)
}

public typealias SYBatchMoyaProviderResponse = (SYTargetType, any SYMoyaNetworkDataResponseProtocol)

/// Batch request item object
public struct SYMoyaBatchProvider<TargetType: SYBatchTatgetType>: SYBatchMoyaProviderType {
    
//    private let grop = DispatchGroup()
//    private let gropNotifyQueue = DispatchQueue(label: "com.shannonyang.SYMoyaNetwork.SYBatchMoyaProvider.grop.notify.queue.\(UUID().uuidString)")
    
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "com.shannonyang.SYMoyaNetwork.BatchRequest.operationQueue"
        return operationQueue
    }()
    
    private let provider: SYMoyaProvider<TargetType>
    public var targetResponsesCompletion: ((_ response: SYBatchDataResponse) -> Void)?

    public mutating func requestTargets(_ progress: SYBatchProgressBlock?, sessionType: SYMoyaBatchProviderSessionType, completion: (SYBatchDataResponse) -> Void) {
        var responses = [SYBatchMoyaProviderResponse]()
        
        let result: Result<[SYBatchMoyaProviderResponse], SYMoyaNetworkError>

//        grop.notify(queue: gropNotifyQueue) {
//            let response = SYBatchDataResponse(result: .success(<#T##[SYBatchMoyaProviderResponse]#>))
//            self.targetResponsesCompletion?(response)
//            completion(response)
//        }
        
        for operation in reqOperations {
            operation.completion = { result in
                switch sessionType {
                case .ifOneFailureBatchFail:
                    switch result {
                    case .success(_):
                        appendResponse()

                    case .failure(let error):
                        operationQueue.cancelAllOperations()
                    }
                case .ifOneFailureBatchContinue:
                    switch result {
                    case .success(_):
                        appendResponse()
                    case .failure(let error):
                        operationQueue.cancelAllOperations()
                    }
                }
                func appendResponse() {
                    let data: any SYMoyaNetworkDataResponseProtocol
                    if let serializer = operation.targetType.serializer {
                        data = serializer.serialize(response: result)
                    } else {
                        data = self.convertToDefaultBatchDataResponse(with: result)
                    }
                    responses.append((operation.targetType,data))
                }
            }
            operationQueue.addOperation(operation)
        }
        operationQueue.addBarrierBlock {
            
        }
    }
    
    public let targetTypes: [TargetType]
    private let reqOperations: [SYMoyaBatchProviderReqOperation<TargetType>]
    
    // MARK: - Initallization
    public init(targetTypes: [TargetType]) {
        self.targetTypes = targetTypes
        self.provider = SYMoyaProvider<TargetType>()
        self.reqOperations = targetTypes.map({ SYMoyaBatchProviderReqOperation(provider: self.provider, targetType: $0) })
    }
}

// MARK: - Private
private extension SYMoyaBatchProvider {
    func convertToDefaultBatchDataResponse(with result: SYMoyaNetworkResult) -> SYMoyaNetworkDataResponse<Data> {
        var dataRes: SYMoyaNetworkDataResponse<Data>
        switch result {
        case .success(let response):
            dataRes = SYMoyaNetworkDataResponse<Data>(response: response, result: .success(response.data))
        case .failure(let error):
            dataRes = SYMoyaNetworkDataResponse<Data>(response: nil, result: .failure(error))
        }
        return dataRes
    }
}
