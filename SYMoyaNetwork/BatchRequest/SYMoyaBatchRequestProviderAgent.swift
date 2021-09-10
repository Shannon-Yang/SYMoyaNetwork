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

public struct BatchMoyaProvider<Target: SYTargetType, T: Decodable, S: BaseMappable> {
    
    public enum ProviderSerializerType {
        case image
        case string(keyPath: String?)
        case json(failsOnEmptyData: Bool = true)
        case codable(decodable: T, keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true)
        case swiftyjson(opt: JSONSerialization.ReadingOptions = [])
        case objectmapper(keyPath: String? = nil, context: MapContext? = nil)
    }
    
    public var targetType: Target
    public var provider: SYMoyaProvider<Target>
    public var serializerType: ProviderSerializerType
}


public enum BatchDataResponseItem {
    case image(SYMoyaNetworkDataResponse<Image>)
    case string(SYMoyaNetworkDataResponse<String>)
    case json(SYMoyaNetworkDataResponse<Any>)
    case codable(SYMoyaNetworkDataResponse<Decodable>)
    case swiftyjson(SYMoyaNetworkDataResponse<SwiftyJSON.JSON>)
    case objectmapper(SYMoyaNetworkDataResponse<BaseMappable>)
}

//public typealias SYMoyaBatchDataResponse = BatchDataResponse<[BatchDataResponseItem], Failure>

public class BatchDataResponse {

    /// The result of response serialization.
    public var result: SYResult<[BatchDataResponseItem]>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: [BatchDataResponseItem]?

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
    public init(result: SYResult<[BatchDataResponseItem]>) {
        self.result = result
        self.value = result.success
    }
}

//public enum BatchData

struct SYMoyaBatchRequestProviderAgent {
    
    static let sharedInstance : SYMoyaBatchRequestProviderAgent = SYMoyaBatchRequestProviderAgent()
    
    fileprivate var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private let queueName = "com.shannonyang.SYMoyaNetwork.BatchRequest.queue.\(UUID().uuidString)"
    
    func response<Target: SYTargetType>(providers: [BatchMoyaProvider<Target>], callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponses: BatchDataResponse) -> Void) {
        
        if providers.isEmpty {
            completion(BatchDataResponse(result: .failure(.batchRequestError(reason: .providersIsEmpty))))
            return
        }
        
        let queue = DispatchQueue(label: queueName, attributes: .concurrent)
        
        var batchDataResponse = BatchDataResponse(result: .success([]))
        
        providers.forEach { provider in
            _ = lock.wait(timeout: DispatchTime.distantFuture)
            //            defer { lock.signal() }
            queue.async {
                switch provider.serializerType {
                case .image:
                    _ = provider.provider.responseImage(provider.targetType, callbackQueue: callbackQueue, progress: progress) { imageDataResponse in
                        switch imageDataResponse.result {
                        case .success(_):
                            batchDataResponse.value?.append(BatchDataResponseItem.image(imageDataResponse))
                        case .failure(let error):
                            batchDataResponse.result = .failure(error)
                            completion(batchDataResponse)
                        }
                    }
                case .string(let keyPath):
                    _ = provider.provider.responseString(provider.targetType, atKeyPath: keyPath, callbackQueue: callbackQueue, progress: progress) { stringDataResponse in
                        switch stringDataResponse.result {
                        case .success(_):
                            batchDataResponse.value?.append(BatchDataResponseItem.string(stringDataResponse))
                        case .failure(let error):
                            batchDataResponse.result = .failure(error)
                            completion(batchDataResponse)
                        }
                    }
                case .json(let failsOnEmptyData):
                    _ = provider.provider.responseJSON(provider.targetType, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress) { jsonDataResponse in
                        switch jsonDataResponse.result {
                        case .success(_):
                            batchDataResponse.value?.append(BatchDataResponseItem.json(jsonDataResponse))
                        case .failure(let error):
                            batchDataResponse.result = .failure(error)
                            completion(batchDataResponse)
                        }
                    }
                case .codable(let decodable, let keyPath, let decoder, let failsOnEmptyData):
                    
                    _ = provider.provider.responseCodableObject<Decodable>(provider.targetType, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData, callbackQueue: callbackQueue, progress: progress) { codableDataResponse in
                        switch codableDataResponse.result {
                        case .success(_):
                            batchDataResponse.value?.append(BatchDataResponseItem.codable(codableDataResponse))
                        case .failure(let error):
                            batchDataResponse.result = .failure(error)
                            completion(batchDataResponse)
                        }
                    }
                case .swiftyjson(let opt):
                    _ = provider.provider.responseSwiftyJSON(provider.targetType, options: opt, callbackQueue: callbackQueue, progress: progress) { swiftyJSONDataResponse in
                        switch swiftyJSONDataResponse.result {
                        case .success(_):
                            batchDataResponse.value?.append(BatchDataResponseItem.swiftyjson(swiftyJSONDataResponse))
                        case .failure(let error):
                            batchDataResponse.result = .failure(error)
                            completion(batchDataResponse)
                        }
                    }
                case .objectmapper(let keyPath, let context):
                    break
                }
            }
        }
    }
}
