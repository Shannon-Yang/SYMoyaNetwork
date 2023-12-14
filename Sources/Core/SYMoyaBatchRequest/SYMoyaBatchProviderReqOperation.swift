//
//  SYMoyaBatchProviderReqOperation.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//

import Foundation
import Moya

public class SYMoyaBatchProviderReqOperation<TargetType: SYTargetType>: AsyncOperation {
    private var cancellable: Cancellable?
    let targetType: TargetType
    var providerResponse: SYMoyaProviderSessionResponse?
    let provider: SYMoyaProvider<TargetType>
    public init(targetType: TargetType) {
        self.targetType = targetType
        self.provider = SYMoyaProvider<TargetType>()
    }
    
    public override func main() {
        self.cancellable = provider.req(targetType) { [weak self] result in
            guard let self else { return }
            self.providerResponse = SYMoyaProviderSessionResponse(self.targetType, result)
            self.finish()
        }
    }
    
    public override func cancel() {
        finish()
        cancellable?.cancel()
    }
}
