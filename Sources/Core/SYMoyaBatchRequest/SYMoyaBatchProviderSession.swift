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

/// Closure to be executed when progress changes.
public typealias SYBatchProgressBlock = (_ progress: SYBatchProgress) -> Void

public struct SYBatchProgress {
    /// An object that conveys ongoing progress for a given request.
    public let progressObject: Progress

    private let count: Int
    /// Initializes a `ProgressResponse`.
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
    
    public var fractionCompleted: Double {
        return progressObject.fractionCompleted
    }

    /// A Boolean value stating whether the request is completed.
    public var completed: Bool { progressObject.isFinished }
    
    func increaseCompletedUnitCount() {
        progressObject.completedUnitCount += 1
    }
}

// Batch request session object, used to session the sending and callback of batch requests
public class SYMoyaBatchProviderSession {
    private let providers: [SYBatchMoyaProviderType]
    public init(providers: [SYBatchMoyaProviderType]) {
        self.providers = providers
    }
    private let queueName = "com.shannonyang.SYMoyaNetwork.BatchRequest.queue.\(UUID().uuidString)"
    
    public func request(_ callbackQueue: DispatchQueue? = .none, progressCompletion: SYBatchProgressBlock? = .none, completion: @escaping (_ result: Result<[SYBatchMoyaProviderResponse?], SYMoyaNetworkError>) -> Void) {
        if providers.isEmpty {
            completion(.failure(.batchRequestError(reason: .providersIsEmpty)))
            return
        }
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        let grop = DispatchGroup()
        var reponses = [SYBatchMoyaProviderResponse?]()
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
