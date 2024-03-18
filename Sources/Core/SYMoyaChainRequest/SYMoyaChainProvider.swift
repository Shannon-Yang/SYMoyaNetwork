//
//  SYMoyaChainProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/16.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Chain Request provider class. Chain Requests should be made through this class only.
public struct SYMoyaChainProvider<TargetType: SYTargetType>: SYChainMoyaProviderType {
    
    /// The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    public let targetType: TargetType
    private let provider: SYMoyaProvider<TargetType>
    private let callbackQueue: DispatchQueue?
    private let progress: ProgressBlock?
    
    // MARK: - Initallization
    
    /// Init `SYMoyaChainProvider`
    ///
    /// - Parameters:
    ///   - targetType: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil.
    ///   - progress: An object that conveys ongoing progress for a given request.
    public init(targetType: TargetType, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil) {
        self.targetType = targetType
        self.callbackQueue = callbackQueue
        self.progress = progress
        self.provider = SYMoyaProvider<TargetType>()
    }

    /// When a chained network request is triggered, Make a network request
    ///
    /// - Parameter completion: A closure which is invoked when the request finish. If `callbackQueue` not specified, the main queue will be used.
    /// - Returns: Protocol to define the opaque type returned from a request.
    @discardableResult
    public func req(completion: @escaping (_ response: SYMoyaProviderSessionResponse) -> Void) -> Cancellable {
        return self.provider.req(targetType, callbackQueue: callbackQueue, progress: progress) { result in
            let response = SYMoyaProviderSessionResponse(self.targetType, result)
            completion(response)
        }
    }
}
