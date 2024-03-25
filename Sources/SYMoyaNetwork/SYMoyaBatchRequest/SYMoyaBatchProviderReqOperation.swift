//
//  SYMoyaBatchProviderReqOperation.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Inherit ``AsyncOperation`` and implement specific tasks for Batch request objects.
public class SYMoyaBatchProviderReqOperation<TargetType: SYTargetType>: AsyncOperation {
    private var cancellable: Cancellable?
    let targetType: TargetType
    var providerResponse: SYMoyaProviderSessionResponse?
    let provider: SYMoyaProvider<TargetType>

    /// Init SYMoyaBatchProviderReqOperation by a protocol used to define the specifications required by `SYMoyaProvider`.
    /// - Parameter  targetType: The protocol used to define the specifications required by `SYMoyaProvider`.
    public init(targetType: TargetType) {
        self.targetType = targetType
        provider = SYMoyaProvider<TargetType>()
    }

    /// Re-parent class method to implement batch request tasks
    override public func main() {
        cancellable = provider.req(targetType) { [weak self] result in
            guard let self else {
                return
            }
            self.providerResponse = SYMoyaProviderSessionResponse(self.targetType, result)
            self.finish()
        }
    }

    /// Cancel tasks for batch requests
    override public func cancel() {
        finish()
        cancellable?.cancel()
    }
}
