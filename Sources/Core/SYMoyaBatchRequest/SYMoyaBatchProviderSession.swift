//
//  SYMoyaBatchProviderSession.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/9.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/// Closure to be executed when progress changes.
public typealias SYBatchProgressBlock = (_ progress: SYBatchProgress) -> Void

/// An object describing the progress of a batch request
public struct SYBatchProgress {
    /// An object that conveys ongoing progress for a given request.
    public let progressObject: Progress

    /// Array object count that implements `SYBatchMoyaProviderType`
    private let count: Int
    
    /// Initializes a `ProgressResponse`.
    /// - Parameter count: Array object count that implements `SYBatchMoyaProviderType`
    public init(count: Int) {
        self.count = count
        self.progressObject = Progress(totalUnitCount: Int64(count))
    }

    /// The fraction of the overall work completed by the progress object.
    public var progressCount: Int64 {
        if progressObject.isFinished {
            return Int64(count)
        }
        
        if progressObject.totalUnitCount > 0 {
            // if the Content-Length is specified we can rely on `fractionCompleted`
            return progressObject.completedUnitCount
        }
        return 0
    }
    
    /// Percentage completed
    public var fractionCompleted: Double {
        return progressObject.fractionCompleted
    }

    /// A Boolean value stating whether the request is completed.
    public var completed: Bool { progressObject.isFinished }
    
    // Increment completed count
    func increaseCompletedUnitCount() {
        progressObject.completedUnitCount += 1
    }
}

/// Batch request session object, used to session the sending and callback of batch requests
///
/// Init `SYMoyaBatchProviderSession` requires an array object that implements `SYBatchMoyaProviderType`.
/// Create a `SYMoyaBatchProviderSession`：
///
/// ```swift
/// let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1),.stream(n: 1)])
/// let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli,.json,.gzipped])
/// let session = SYMoyaBatchProviderSession(providers: [provider,provider2])
/// ```
/// When a batch request is initiated, the concurrent queue will be initialized based on the `providers` array.
public class SYMoyaBatchProviderSession {
    private let providers: [SYBatchMoyaProviderType]
    
    /// Init`SYMoyaBatchProviderSession` with `SYBatchMoyaProviderType` array
    ///
    /// - Parameter providers: Array object that implements `SYBatchMoyaProviderType`
    public init(providers: [SYBatchMoyaProviderType]) {
        self.providers = providers
    }
    private let queueName = "com.shannonyang.SYMoyaNetwork.BatchRequest.queue.\(UUID().uuidString)"
    
    /// Make a batch request
    ///
    /// This method will build some concurrent queue to request data, and will initialize a `DispatchGroup` object to listen for the completion of the task. Completion will be called back after completion.
    ///
    /// ```swift
    /// let provider = SYMoyaBatchProvider<HTTPBinDynamicData>(targetTypes: [.getDelay(delay: 1),.stream(n: 1)])
    /// let provider2 = SYMoyaBatchProvider<HTTPBinResponseFormats>(targetTypes: [.brotli,.json,.gzipped])
    /// let session = SYMoyaBatchProviderSession(providers: [provider,provider2])
    /// session?.request { [weak self] progress in
    /// DispatchQueue.main.async {
    ///        self?.progressView.progress = Float(progress.fractionCompleted)
    ///   }
    /// } completion: { [weak self] result in
    ///   // do some
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is none and will be called back on the main thread.
    ///   - progressCompletion: Progress callback block
    ///   - completion: A closure which is invoked when the batch operation finishes. If not specified, the main queue will be used.
    public func request(_ callbackQueue: DispatchQueue? = .none, progressCompletion: SYBatchProgressBlock? = .none, completion: @escaping (_ result: Result<[SYMoyaProviderSessionResponse?], SYMoyaNetworkError>) -> Void) {
        if providers.isEmpty {
            completion(.failure(.batchRequestError(reason: .providersIsEmpty)))
            return
        }
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        let grop = DispatchGroup()
        var reponses = [SYMoyaProviderSessionResponse?]()
        let count = providers.reduce(0) { partialResult, providerType in
            partialResult + providerType.targetTypeCount
        }
        let progress = SYBatchProgress(count: count)
        for provider in providers {
            grop.enter()
            queue.async(group: grop) {
                provider.requestTargets {
                    progress.increaseCompletedUnitCount()
                    if let progressCompletion {
                        progressCompletion(progress)
                    }
                } _: { responses in
                    reponses.append(contentsOf: responses)
                    grop.leave()
                }
            }
        }
        let notifyQueue = callbackQueue ?? .main
        grop.notify(queue: notifyQueue) {
            completion(.success(reponses))
        }
    }
}
