//
//  SYMoyaBatchProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//

import Foundation
import Moya

public protocol SYBatchMoyaProviderType {
    var targetTypeCount: Int { get }
    func requestTargets(_ reqOperationCompletion: @escaping () -> Void, _ completion: @escaping (_ responses: [SYBatchMoyaProviderResponse?]) -> Void)
}

public typealias SYBatchMoyaProviderResponse = (targetType: SYTargetType, result: SYMoyaNetworkResult)

/// Batch request item object
public class SYMoyaBatchProvider<TargetType: SYTargetType>: SYBatchMoyaProviderType {
    public var targetTypeCount: Int {
        return targetTypes.count
    }
    
    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "com.shannonyang.SYMoyaNetwork.BatchRequest.operationQueue"
        return operationQueue
    }()
    
    private let targetTypes: [TargetType]
    
    // MARK: - Initallization
    public init(targetTypes: [TargetType]) {
        self.targetTypes = targetTypes
    }
    
    public func requestTargets(_ reqOperationCompletion: @escaping () -> Void, _ completion: @escaping (_ responses: [SYBatchMoyaProviderResponse?]) -> Void) {
        let reqOperations: [SYMoyaBatchProviderReqOperation<TargetType>] = targetTypes.map {
            SYMoyaBatchProviderReqOperation(targetType: $0)
        }
        reqOperations.forEach({
            $0.completionBlock = {
                reqOperationCompletion()
            }
        })
        operationQueue.addOperations(reqOperations, waitUntilFinished: true)
        operationQueue.addBarrierBlock {
            let providerResponses = reqOperations.map { $0.providerResponse }
            completion(providerResponses)
        }
    }
}
