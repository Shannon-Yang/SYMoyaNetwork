//
//  SYMoyaPublisher.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/9/15.
//

#if canImport(Combine)

import Combine
import Moya

// This should be already provided in Combine, but it's not.
// Ideally we would like to remove it, in favor of a framework-provided solution, ASAP.
/*
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
internal class SYMoyaPublisher<Output>: Publisher {
    associatedtype Out
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
    }
}*/
#endif
