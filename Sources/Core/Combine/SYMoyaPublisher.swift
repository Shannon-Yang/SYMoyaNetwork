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

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
internal class SYMoyaPublisher<Output>: Publisher {

    internal typealias Failure = SYMoyaNetworkError

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

    private let callback: (AnySubscriber<Output, SYMoyaNetworkError>) -> Moya.Cancellable?

    init(callback: @escaping (AnySubscriber<Output, SYMoyaNetworkError>) -> Moya.Cancellable?) {
        self.callback = callback
    }

    internal func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber), callback: callback)
        subscriber.receive(subscription: subscription)
    }
}

#endif