//
//  SYMoyaPublisher.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/9/15.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Combine
import Moya

// This should be already provided in Combine, but it's not.
// Ideally we would like to remove it, in favor of a framework-provided solution, ASAP.
public class SYMoyaPublisher<Output>: Publisher {
    /// The failure type is Never
    public typealias Failure = Never
    /// An object that implements ``Combine/Subscription``
    private class Subscription: Combine.Subscription {
        private let performCall: () -> Moya.Cancellable?
        private var cancellable: Moya.Cancellable?
        
        /// Init Subscription
        ///
        /// - Parameters:
        ///   - subscriber: A type-erasing subscriber.
        ///   - callback: Callback a `AnySubscriber` object and will return A protocol indicating that an activity or action supports cancellation.
        init(subscriber: AnySubscriber<Output, Failure>, callback: @escaping (AnySubscriber<Output, Failure>) -> Moya.Cancellable?) {
            performCall = { callback(subscriber) }
        }
        
        /// Tells a publisher that it may send more values to the subscriber.
        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else { return }
            cancellable = performCall()
        }
        /// Cancels the represented request.
        func cancel() {
            cancellable?.cancel()
        }
    }
    
    let callback: (AnySubscriber<Output, Failure>) -> Moya.Cancellable?
    
    
    /// Init SYMoyaPublisher
    ///
    /// - Parameter callback: Callback a `AnySubscriber` object and will return A protocol indicating that an activity or action supports cancellation.
    public init(callback: @escaping (AnySubscriber<Output, Failure>) -> Moya.Cancellable?) {
        self.callback = callback
    }
    
    
    /// Attaches the specified subscriber to this publisher.
    ///
    /// Implementations of `Publisher` must implement this method.
    ///
    /// The provided implementation of `Publisher/subscribe(_:)` calls this method.
    ///
    /// - Parameter subscriber: The subscriber to attach to this `Publisher`, after which it can receive values.
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber), callback: callback)
        subscriber.receive(subscription: subscription)
    }
}




