//
//  SYMoyaChainRequestProviderAgent.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/9/13.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// Chain request abstract protocol
public protocol SYChainMoyaProviderType {
    
    /// When a chained network request is triggered, Make a network request
    ///
    /// - Parameter completion: A closure which is invoked when the request finish. If `callbackQueue` not specified, the main queue will be used.
    /// - Returns: Protocol to define the opaque type returned from a request.
    func req(completion: @escaping (_ response: SYMoyaProviderSessionResponse) -> Void) -> Cancellable
}

/// The chained request provider is used to manage interdependent network requests, and it can actually eventually be used to manage multiple topologically sorted network requests.
public struct SYMoyaChainProviderSession {
    
    /// Make chain request
    ///
    /// ``` swift
    /// let chainProvider = SYMoyaChainProvider(targetType: HTTPBinAuth.bearer) { progress in
    ///   debugPrint("🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️----> \(progress) <---- < Class: \(type(of: self)) Function:\(#function) Line: \(#line) >🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️🏃🏻‍♀️")
    /// }
    /// SYMoyaChainProviderSession.request(chainMoyaProviderType: chainProvider) { response in
    ///    // Determine whether it is necessary to trigger the next request in the chain request
    /// } completion: {
    ///    // do some finished
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - chainMoyaProviderType: Object that implements SYChainMoyaProviderType
    ///   - nextChainProviderType: To determine whether the next request in the chain request needs to be triggered, this callback needs to return an object that                               implements `SYChainMoyaProviderType`, usually `SYMoyaChainProvider`.
    ///   - completion: Callback after the chain request is completed
    /// - Returns: Protocol to define the opaque type returned from a request.
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
