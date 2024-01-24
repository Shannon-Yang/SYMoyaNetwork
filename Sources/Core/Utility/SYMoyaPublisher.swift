//
//  SYMoyaPublisher.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/9/15.
//

import Combine
import Moya

// This should be already provided in Combine, but it's not.
// Ideally we would like to remove it, in favor of a framework-provided solution, ASAP.
public class SYMoyaPublisher<Output>: Publisher {
    public typealias Failure = Never
    private class Subscription: Combine.Subscription {
        private let performCall: () -> Moya.Cancellable?
        private var cancellable: Moya.Cancellable?
        
        init(subscriber: AnySubscriber<Output, Failure>, callback: @escaping (AnySubscriber<Output, Failure>) -> Moya.Cancellable?) {
            performCall = { callback(subscriber) }
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else { return }
            cancellable = performCall()
        }
        
        func cancel() {
            cancellable?.cancel()
        }
    }
    
    let callback: (AnySubscriber<Output, Failure>) -> Moya.Cancellable?
    
    public init(callback: @escaping (AnySubscriber<Output, Failure>) -> Moya.Cancellable?) {
        self.callback = callback
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber), callback: callback)
        subscriber.receive(subscription: subscription)
    }
}



