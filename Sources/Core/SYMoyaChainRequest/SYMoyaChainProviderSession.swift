//
//  SYMoyaChainRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/13.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol SYChainMoyaProviderType {
    func req(completion: @escaping (_ response: SYMoyaProviderSessionResponse) -> Void) -> Cancellable
}

/// The chained request provider is used to manage interdependent network requests, and it can actually eventually be used to manage multiple topologically sorted network requests.
public struct SYMoyaChainProviderSession {
    @discardableResult
    public static func request(chainMoyaProviderType: SYChainMoyaProviderType, nextChainProviderTypeIfNeeded nextChainProviderType: @escaping (_ response: SYMoyaProviderSessionResponse) -> SYChainMoyaProviderType?, completion: (() -> Void)? = nil) -> Cancellable? {
        return reqIfNeeded(chainMoyaProviderType: chainMoyaProviderType)
        @discardableResult
        func reqIfNeeded(chainMoyaProviderType: SYChainMoyaProviderType?) -> Cancellable? {
            if let chainMoyaProviderType {
                return chainMoyaProviderType.req { response in
                    let next = nextChainProviderType(response)
                    reqIfNeeded(chainMoyaProviderType: next)
                }
            } else {
                completion?()
                return nil
            }
        }
    }
}
