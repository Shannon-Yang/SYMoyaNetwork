//
//  SYMoyaChainRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/13.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public struct ChainProvider<Target: SYTargetType> {
    var target: Target
    var provider: SYMoyaProvider<Target>
    init(_ target: Target, provider: SYMoyaProvider<Target>) {
        self.target = target
        self.provider = provider
    }
}

public struct ChainResult<Target: SYTargetType> {
    public var chainProvider: ChainProvider<Target>
    public var response: Moya.Response
}

public class ChainDataResponse<Target: SYTargetType> {

    /// The result of response serialization.
    public var result: SYResult<ChainResult<Target>>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: ChainResult<Target>?

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
    public init(result: SYResult<ChainResult<Target>>) {
        self.result = result
        self.value = result.success
    }
}

struct SYMoyaChainRequestProvider<Target: SYTargetType> {
    
    typealias ChainCompletion = (_ dataResponses: BatchDataResponse<Target>) -> Void
    
    private var chainCompletions = [ChainCompletion]()
    
    func addChainProvider(_ callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, chainProvider: ChainProvider<Target>, completion: @escaping (_ dataResponses: ChainDataResponse<Target>) -> Void) {
        
        chainProvider.provider.request(chainProvider.target, callbackQueue: callbackQueue, progress: progress) { result in
            switch result {
            case .success(let response):
                let re: ChainResult<Target> = ChainResult(chainProvider: chainProvider, response: response)
                // TODO: Shannon Yang 👺 
                completion(.init(result: .success(re)))
            case .failure(let error):
                completion(.init(result: .failure(error.transformToSYMoyaNetworkError())))
            }
        }
    }
}
