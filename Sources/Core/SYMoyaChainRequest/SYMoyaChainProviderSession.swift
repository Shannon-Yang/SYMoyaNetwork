//
//  SYMoyaChainRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/13.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Chain request data return result delegate callback, when the chain request succeeds or fails, the delegate method is called back
public protocol SYMoyaChainProviderSessionDelegate: NSObjectProtocol {
    
    /// Callback after successful chain request
    /// - Parameter provider: The chained request provider is used to manage interdependent network requests
    func chainProviderRequestFinished(_ session: SYMoyaChainProviderSession)
    
    /// Callback after fail chain request
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - error: network request error object
    func chainProvider<Target: SYSerializableTatgetType>(_ session: SYMoyaChainProviderSession, requestFailed provider: SYMoyaChainProvider<Target>, failedError error: SYMoyaNetworkError)
}

protocol SYChainMoyaProviderType {
    func req(completion: @escaping (_ result: SYMoyaNetworkResult) -> Void)
}

/// The chained request provider is used to manage interdependent network requests, and it can actually eventually be used to manage multiple topologically sorted network requests.
public class SYMoyaChainProviderSession {
    weak var delegate: SYMoyaChainProviderSessionDelegate?
    var providers = [SYChainMoyaProviderType]()
    var operations = [Operation]()
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.shannonyang.SYMoyaNetwork.ChainRequest.queue.\(UUID().uuidString)"
        return queue
    }()
    
    /// Add a network request provider
    /// - Parameter provider: The chained request provider is used to manage interdependent network requests
    public func addChainProvider<Target: SYSerializableTatgetType>(target: Target, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil, completion: ((_ result: SYMoyaNetworkResult) -> Void)?) {
        let provider = SYMoyaChainProvider<Target>(target: target, callbackQueue: callbackQueue, progress: progress)
        self.providers.append(provider)
        let operation = BlockOperation { [weak self] in
            guard let self else { return }
            provider.req { result in
                switch result {
                case .success(_):
                    completion?(result)
                case .failure(let failure):
                    self.queue.cancelAllOperations()
                    self.delegate?.chainProvider(self, requestFailed: provider, failedError: failure)
                }
            }
        }
        if let last = self.operations.last {
            operation.addDependency(last)
        }
        self.queue.addOperation(operation)
    }
    
    /// initiate a chain request
    public func request() {
        if self.providers.isEmpty {
            print("Error! Chain request array is empty.")
            return
        }
        self.queue.addBarrierBlock { [weak self] in
            guard let self else { return }
            self.delegate?.chainProviderRequestFinished(self)
        }
    }
}
