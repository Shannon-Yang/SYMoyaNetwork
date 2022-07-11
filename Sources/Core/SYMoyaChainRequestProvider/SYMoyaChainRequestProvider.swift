//
//  SYMoyaChainRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/13.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

// Chain request item object
public struct ChainProvider<Target: SYTargetType> {
    var target: Target
    var provider: SYMoyaProvider<Target>
    
    public typealias ChainCompletion = (_ dataResponses: ChainDataResponse<Target>) -> Void
    
    public var callbackQueue: DispatchQueue? = .none
    public var progress: ProgressBlock? = .none
    
    public let chainCompletion: ChainCompletion
    
    init(_ target: Target, provider: SYMoyaProvider<Target>, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none,  chainCompletion: @escaping ChainCompletion) {
        self.target = target
        self.provider = provider
        self.callbackQueue = callbackQueue
        self.progress = progress
        self.chainCompletion = chainCompletion
    }
}

/// Chained request data return result
public struct ChainResult<Target: SYTargetType> {
    public var chainProvider: ChainProvider<Target>
    public var response: Moya.Response
}


/// Chained request data response
public class ChainDataResponse<Target: SYTargetType> {

    /// The result of response serialization.
    public var result: Result<ChainResult<Target>, SYMoyaNetworkError>

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
    public init(result: Result<ChainResult<Target>, SYMoyaNetworkError>) {
        self.result = result
        self.value = result.success
    }
}

/// Chain request data return result delegate callback, when the chain request succeeds or fails, the delegate method is called back
public protocol SYMoyaChainRequestProviderDelegate: NSObjectProtocol {
    
    /// Callback after successful chain request
    /// - Parameter provider: The chained request provider is used to manage interdependent network requests
    func chainProviderRequestFinished<Target: SYTargetType>(_ provider: SYMoyaChainRequestProvider<Target>)
    
    /// Callback after fail chain request
    /// - Parameters:
    ///   - provider: The chained request provider is used to manage interdependent network requests
    ///   - error: network request error object
    func chainProvider<Target: SYTargetType>(_ provider: SYMoyaChainRequestProvider<Target>, requestFailed error: SYMoyaNetworkError)
}


/// The chained request provider is used to manage interdependent network requests, and it can actually eventually be used to manage multiple topologically sorted network requests.
public class SYMoyaChainRequestProvider<Target: SYTargetType> {
    
    weak var delegate: SYMoyaChainRequestProviderDelegate?
    
    var providers = [ChainProvider<Target>]()
    
    private var nextProvidertIndex = 0
    
    
    /// Add a network request provider
    /// - Parameter provider: The chained request provider is used to manage interdependent network requests
    public func addChainProvider(_ provider: ChainProvider<Target>) {
        self.providers.append(provider)
    }
    
    
    /// initiate a chain request
    public func request() {
        if self.nextProvidertIndex > 0 {
            print("Error! Chain request has already started.")
            return
        }
        if self.providers.isEmpty {
            print("Error! Chain request array is empty.")
            return
        }
        _ = self.startNext()
    }
    
}

// MARK: - ChainRequestProvider

extension SYMoyaChainRequestProvider {
    
    func req(_ chainProvider: ChainProvider<Target>) {
        chainProvider.provider.request(chainProvider.target, callbackQueue: chainProvider.callbackQueue, progress: chainProvider.progress) { result in
            switch result {
            case .success(let response):
                // call back
                let re: ChainResult<Target> = ChainResult(chainProvider: chainProvider, response: response)
                let dataResponse: ChainDataResponse<Target> = ChainDataResponse(result: .success(re))
                chainProvider.chainCompletion(dataResponse)
                
                if !self.startNext() {
                    self.delegate?.chainProviderRequestFinished(self)
                }
            case .failure(let error):
                self.delegate?.chainProvider(self, requestFailed: error.transformToSYMoyaNetworkError())
            }
        }
    }
    
    func startNext() -> Bool {
        if self.nextProvidertIndex < self.providers.count {
            let provider = self.providers[self.nextProvidertIndex]
            self.nextProvidertIndex += 1
            self.req(provider)
            return true
        }
        return false
    }
}
