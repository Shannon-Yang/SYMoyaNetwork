//
//  SYDataTask.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/6/18.
//

import Foundation
import Moya

/// Value used to `await` a `DataResponse` and associated values.
/*
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct DataTask<Value> {
    /// `DataResponse` produced by the `DataRequest` and its response handler.
    public var response: SYDataResponse<Value, SYMoyaNetworkError> {
        get async {
            if shouldAutomaticallyCancel {
                return await withTaskCancellationHandler {
                    await task.value
                } onCancel: {
                    cancel()
                }
            } else {
                return await task.value
            }
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    public var result: Result<Value, SYMoyaNetworkError> {
        get async { await response.result }
    }

    /// `Value` returned by the `response`.
    public var value: Value {
        get async throws {
            try await result.get()
        }
    }

    private let cancellable: Moya.Cancellable?
    private let task: Task<SYDataResponse<Value, SYMoyaNetworkError>, Never>
    private let shouldAutomaticallyCancel: Bool

    fileprivate init(cancellable: Moya.Cancellable?, task: Task<SYDataResponse<Value, SYMoyaNetworkError>, Never>, shouldAutomaticallyCancel: Bool) {
        self.cancellable = cancellable
        self.task = task
        self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
    }

    /// Cancel the underlying `DataRequest` and `Task`.
    public func cancel() {
        cancellable?.cancel()
    }
}*/
