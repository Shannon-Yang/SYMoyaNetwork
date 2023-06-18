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



@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public struct SYMoyaDataResponsePublisher<Value>: Publisher {
    public typealias Output = SYMoyaNetworkDataResponse<Value>
    public typealias Failure = Never

    private typealias Handler = (@escaping (_ response: SYMoyaNetworkDataResponse<Value>) -> Void) -> Moya.Cancellable?

    private let request: DataRequest
    private let responseHandler: Handler

    /// Creates an instance which will serialize responses using the provided `ResponseSerializer`.
    ///
    /// - Parameters:
    ///   - request:    `DataRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `DataResponse` value will be published. `.main` by default.
    ///   - serializer: `ResponseSerializer` used to produce the published `DataResponse`.
    public init<Serializer: ResponseSerializer>(_ request: DataRequest, queue: DispatchQueue, serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        responseHandler = { request.response(queue: queue, responseSerializer: serializer, completionHandler: $0) }
    }

    /// Creates an instance which will serialize responses using the provided `DataResponseSerializerProtocol`.
    ///
    /// - Parameters:
    ///   - request:    `DataRequest` for which to publish the response.
    ///   - queue:      `DispatchQueue` on which the `DataResponse` value will be published. `.main` by default.
    ///   - serializer: `DataResponseSerializerProtocol` used to produce the published `DataResponse`.
    public init<Serializer: DataResponseSerializerProtocol>(_ request: DataRequest,
                                                            queue: DispatchQueue,
                                                            serializer: Serializer)
        where Value == Serializer.SerializedObject {
        self.request = request
        responseHandler = { request.response(queue: queue, responseSerializer: serializer, completionHandler: $0) }
    }

    /// Publishes only the `Result` of the `DataResponse` value.
    ///
    /// - Returns: The `AnyPublisher` publishing the `Result<Value, AFError>` value.
    public func result() -> AnyPublisher<Output, Never> {
        map(\.result).eraseToAnyPublisher()
    }

    /// Publishes the `Result` of the `DataResponse` as a single `Value` or fail with the `AFError` instance.
    ///
    /// - Returns: The `AnyPublisher<Value, AFError>` publishing the stream.
    public func value() -> AnyPublisher<Output, Never> {
        setFailureType(to: AFError.self).flatMap(\.result.publisher).eraseToAnyPublisher()
    }

    public func receive<S>(subscriber: S) where S: Subscriber, DataResponsePublisher.Failure == S.Failure, DataResponsePublisher.Output == S.Input {
        subscriber.receive(subscription: Inner(request: request,
                                               responseHandler: responseHandler,
                                               downstream: subscriber))
    }

    private final class Inner<Downstream: Subscriber>: Subscription
        where Downstream.Input == Output {
        typealias Failure = Downstream.Failure

        @Protected
        private var downstream: Downstream?
        private let request: DataRequest
        private let responseHandler: Handler

        init(request: DataRequest, responseHandler: @escaping Handler, downstream: Downstream) {
            self.request = request
            self.responseHandler = responseHandler
            self.downstream = downstream
        }

        func request(_ demand: Subscribers.Demand) {
            assert(demand > 0)

            guard let downstream = downstream else { return }

            self.downstream = nil
            responseHandler { response in
                _ = downstream.receive(response)
                downstream.receive(completion: .finished)
            }.resume()
        }

        func cancel() {
            request.cancel()
            downstream = nil
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension DataResponsePublisher where Value == Data? {
    /// Creates an instance which publishes a `DataResponse<Data?, AFError>` value without serialization.
    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public init(_ request: DataRequest, queue: DispatchQueue) {
        self.request = request
        responseHandler = { request.response(queue: queue, completionHandler: $0) }
    }
}
#endif




