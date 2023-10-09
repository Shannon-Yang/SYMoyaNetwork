//
//  SYMoyaBatchProviderReqOperation.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//

import Foundation
import Moya

public class SYMoyaBatchProviderReqOperation<TargetType: SYBatchTatgetType>: AsyncOperation {
    private weak var provider: SYMoyaProvider<TargetType>?
    let targetType: TargetType
    private var cancellable: Cancellable?
    var completion : ((_ result: SYMoyaNetworkResult) -> Void)?
    
    public init(provider: SYMoyaProvider<TargetType>,targetType: TargetType) {
        self.provider = provider
        self.targetType = targetType
    }
    
    public override func main() {
        self.cancellable = provider?.req(targetType, progress: nil) { [weak self] result in
            self?.completion?(result)
            self?.finish()
        }
    }
    
    public override func cancel() {
        self.cancellable?.cancel()
    }
}
