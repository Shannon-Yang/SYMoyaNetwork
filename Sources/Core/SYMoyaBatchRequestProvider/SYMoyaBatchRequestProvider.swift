//
//  SYMoyaBatchRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/9.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol SYBatchMoyaProviderType {
    func requestTargets(_ callbackQueue: DispatchQueue?, completion: ([SYMoyaNetworkDataResponse<Data>]) -> Void)
}

/// Batch request item object
public struct SYBatchMoyaProvider<Target: SYTargetType>: SYBatchMoyaProviderType {
    public func requestTargets(_ callbackQueue: DispatchQueue?, completion: ([SYMoyaNetworkDataResponse<Data>]) -> Void) {
        for item in targetTypes {
            provider.req(item, callbackQueue: callbackQueue, progress: <#T##ProgressBlock?##ProgressBlock?##(_ progress: ProgressResponse) -> Void#>, completion: <#T##((Result<Response, SYMoyaNetworkError>) -> Void)##((Result<Response, SYMoyaNetworkError>) -> Void)##(_ result: Result<Response, SYMoyaNetworkError>) -> Void#>)
        }
    }
    
    public let targetTypes: [Target]
    public let provider: SYMoyaProvider<Target>
    
    // MARK: - Initallization
    public init(targets: [Target]) {
        self.provider = SYMoyaProvider<Target>()
    }
}

/// Batch request returns result object
public struct SYBatchRequestResult {
    public let batchProvider: SYBatchMoyaProviderType
    public let response: Moya.Response
    
    // MARK: - Initallization
    public init(batchProvider: BatchMoyaProvider<Target>,response: Moya.Response) {
        self.batchProvider = batchProvider
        self.response = response
    }
}

/// Batch request data response
public class BatchDataResponse<Target: SYTargetType> {

    /// The result of response serialization.
    public var result: Result<[BatchResult<Target>], SYMoyaNetworkError>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: [BatchResult<Target>]?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: SYMoyaNetworkError? { result.failure }

    /// Creates a `SYDataResponse` instance with the specified parameters derived from the response serialization.
    ///
    /// - Parameters:
    ///   - request:               The `URLRequest` sent to the server.
    ///   - response:              The `HTTPURLResponse` from the server.
    ///   - data:                  The `Data` returned by the server.
    ///   - metrics:               The `URLSessionTaskMetrics` of the `DataRequest` or `UploadRequest`.
    ///   - serializationDuration: The duration taken by serialization.
    ///   - result:                The `Result` of response serialization.
    public init(result: Result<[BatchResult<Target>], SYMoyaNetworkError>) {
        self.result = result
        self.value = result.success
    }
}

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
    

    public init(providers: [SYBatchMoyaProviderType]) {
        self.providers = providers
    }
    
    fileprivate var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    private let queueName = "com.shannonyang.SYMoyaNetwork.BatchRequest.queue.\(UUID().uuidString)"
    
    /// Make a batch request
    /// - Parameters:
    ///   - callbackQueue: Callback thread, the default is none, the default is the main thread
    ///   - progress: Data request progress
    ///   - completion: The request progress indicates the sum of the request progress of all providers
    public func request(_ callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponses: BatchDataResponse<Target>) -> Void) {
        if providers.isEmpty {
            completion(BatchDataResponse(result: .failure(.batchRequestError(reason: .providersIsEmpty))))
            return
        }
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        let batchDataResponse = BatchDataResponse<Target>(result: .success([]))
        
        self.providers.forEach { provider in
            _ = lock.wait(timeout: DispatchTime.distantFuture)
            defer { lock.signal() }
            queue.async {
                provider.provider.request(provider.targetType, callbackQueue: callbackQueue, progress: progress) { result in
                    switch result {
                    case .success(let response):
                        let re: BatchResult<Target> = BatchResult(batchProvider: provider, response: response)
                        batchDataResponse.value?.append(re)
                    case .failure(let error):
                        batchDataResponse.result = .failure(error.transformToSYMoyaNetworkError())
                        completion(batchDataResponse)
                    }
                    self.lock.signal()
                }
            }
        }
    }
 
}
