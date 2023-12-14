//
//  SYMoyaChainProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/16.
//

import Foundation
import Moya

// Chain request item object
public struct SYMoyaChainProvider<TargetType: SYTargetType>: SYChainMoyaProviderType {
    public let targetType: TargetType
    private let provider: SYMoyaProvider<TargetType>
    private let callbackQueue: DispatchQueue?
    private let progress: ProgressBlock?
    
    // MARK: - Initallization
    public init(targetType: TargetType, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil) {
        self.targetType = targetType
        self.callbackQueue = callbackQueue
        self.progress = progress
        self.provider = SYMoyaProvider<TargetType>()
    }
    
    @discardableResult
    public func req(completion: @escaping (_ response: SYMoyaProviderSessionResponse) -> Void) -> Cancellable {
        return self.provider.req(targetType, callbackQueue: callbackQueue, progress: progress) { result in
            let response = SYMoyaProviderSessionResponse(self.targetType, result)
            completion(response)
        }
    }
}
