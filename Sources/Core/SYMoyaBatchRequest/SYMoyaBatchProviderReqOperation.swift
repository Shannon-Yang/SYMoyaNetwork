//
//  SYMoyaBatchProviderReqOperation.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/9/5.
//

import Foundation
import Moya

public class SYMoyaBatchProviderReqOperation<TargetType: SYTargetType>: AsyncOperation {
    private weak var provider: SYMoyaProvider<TargetType>?
    private var cancellable: Cancellable?
    let targetType: TargetType
    var completion : ((_ result: SYMoyaNetworkResult) -> Void)?
    
    public init(targetType: TargetType, provider: SYMoyaProvider<TargetType>) {
        self.targetType = targetType
        self.provider = provider
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
