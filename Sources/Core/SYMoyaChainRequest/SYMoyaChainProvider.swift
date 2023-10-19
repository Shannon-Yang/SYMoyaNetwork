//
//  SYMoyaChainProvider.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/16.
//

import Foundation
import Moya

// Chain request item object
public struct SYMoyaChainProvider<Target: SYSerializableTatgetType>: SYChainMoyaProviderType {
    public let target: Target
    let provider: SYMoyaProvider<Target>
    public var callbackQueue: DispatchQueue?
    public var progress: ProgressBlock?
    
    // MARK: - Initallization
    public init(target: Target, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock? = nil) {
        self.target = target
        self.provider = SYMoyaProvider<Target>()
        self.callbackQueue = callbackQueue
        self.progress = progress
    }
    
    func req(completion: @escaping (_ result: SYMoyaNetworkResult) -> Void) {
        self.provider.req(target, callbackQueue: callbackQueue, progress: progress) { result in
            completion(result)
        }
    }
}
