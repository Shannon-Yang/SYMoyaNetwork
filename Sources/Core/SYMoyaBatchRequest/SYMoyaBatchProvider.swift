//
//  SYMoyaBatchProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Batch request abstract protocol
public protocol SYBatchMoyaProviderType {
    /// The number of protocols used to define the specifications required by `SYMoyaProvider`.
    var targetTypeCount: Int { get }
    
    /// Make a batch request
    ///
    /// - Parameters:
    ///   - reqOperationCompletion: Callback after each TargetType request is completed
    ///   - completion: Callback after all batch requests are completed. This method will build an `OperationQueue` internally and callback completion after the `OperationQueue` completes all tasks.
    func requestTargets(_ reqOperationCompletion: @escaping () -> Void, _ completion: @escaping (_ responses: [SYMoyaProviderSessionResponse?]) -> Void)
}

/// Batch Request provider class. Batch Requests should be made through this class only.
public class SYMoyaBatchProvider<TargetType: SYTargetType>: SYBatchMoyaProviderType {
    /// The number of protocols used to define the specifications required by `SYMoyaProvider`.
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
    
    /// Init SYMoyaBatchProvider
    /// - Parameter targetTypes: The array of protocols used to define the specifications required by `SYMoyaProvider`.
    public init(targetTypes: [TargetType]) {
        self.targetTypes = targetTypes
    }
    
    /// Make a batch request
    ///
    /// - Parameters:
    ///   - reqOperationCompletion: Callback after each TargetType request is completed
    ///   - completion: Callback after all batch requests are completed. This method will build an `OperationQueue` internally and callback completion after the `OperationQueue` completes all tasks.
    public func requestTargets(_ reqOperationCompletion: @escaping () -> Void, _ completion: @escaping (_ responses: [SYMoyaProviderSessionResponse?]) -> Void) {
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
