//
//  SYMoyaBatchRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/9.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya
import SwiftyJSON

public struct BatchMoyaProvider<Target: SYTargetType> {
    public var targetType: Target
    public var provider: SYMoyaProvider<Target>
}

public struct BatchResult<Target: SYTargetType> {
    public var batchProvider: BatchMoyaProvider<Target>
    public var response: Moya.Response
}

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

//public enum BatchData

class SYMoyaBatchRequestProvider<Target: SYTargetType> {
    
    private let providers: [BatchMoyaProvider<Target>]
    
    init(providers: [BatchMoyaProvider<Target>]) {
        self.providers = providers
    }
    
    
    fileprivate var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private let queueName = "com.shannonyang.SYMoyaNetwork.BatchRequest.queue.\(UUID().uuidString)"
    
    func request(_ callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponses: BatchDataResponse<Target>) -> Void) {
        
        if providers.isEmpty {
            completion(BatchDataResponse(result: .failure(.batchRequestError(reason: .providersIsEmpty))))
            return
        }
        
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        
        let batchDataResponse = BatchDataResponse<Target>(result: .success([]))
        
        providers.forEach { provider in
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
