//
//  SYDataResponse.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/9/6.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public typealias SYMoyaNetworkDataResponse<Success> = SYDataResponse<Success>

public struct SYDataResponse<Success> {

    public let response: Moya.Response?
    
    public var isDataFromCache: Bool

    /// The result of response serialization.
    public let result: SYResult<Success>

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: Success? { result.success }

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: SYMoyaNetworkError? { result.failure }

    /// Creates a `SYDataResponse` instance with the specified parameters derived from the response serialization.
    ///
    /// - Parameters:
    ///   - request:               The `URLRequest` sent to the server.
    ///   - response:              The `HTTPURLResponse` from the server.
    ///   - data:                  The `Data` returned by the server.
    ///   - metrics:               The `URLSessionTaskMetrics` of the `DataRequest` or `UploadRequest`.
    ///   - serializationDuration: The duration taken by serialization.
    ///   - result:                The `Result` of response serialization.
    public init(response: Moya.Response?, isDataFromCache: Bool = false,
                result: SYResult<Success>) {
        self.response = response
        self.isDataFromCache = isDataFromCache
        self.result = result
    }
}

// MARK: -

extension SYDataResponse {
    /// Evaluates the specified closure when the result of this `SYDataResponse` is a success, passing the unwrapped
    /// result value as a parameter.
    ///
    /// Use the `map` method with a closure that does not throw. For example:
    ///
    ///     let possibleData: SYDataResponse<JSON> = ...
    ///     let possibleInt = possibleData.map { $0.count }
    ///
    /// - parameter transform: A closure that takes the success value of the instance's result.
    ///
    /// - returns: A `SYDataResponse` whose result wraps the value returned by the given closure. If this instance's
    ///            result is a failure, returns a response wrapping the same failure.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> SYDataResponse<NewSuccess, Failure> {
        SYDataResponse<NewSuccess, Failure>(response: response, isDataFromCache: isDataFromCache, result: result.map(transform))
    }

    /// Evaluates the given closure when the result of this `SYDataResponse` is a success, passing the unwrapped result
    /// value as a parameter.
    ///
    /// Use the `tryMap` method with a closure that may throw an error. For example:
    ///
    ///     let possibleData: SYDataResponse<JSON> = ...
    ///     let possibleObject = possibleData.tryMap {
    ///         try JSONSerialization.jsonObject(with: $0)
    ///     }
    ///
    /// - parameter transform: A closure that takes the success value of the instance's result.
    ///
    /// - returns: A success or failure `SYDataResponse` depending on the result of the given closure. If this instance's
    ///            result is a failure, returns the same failure.
    public func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> SYDataResponse<NewSuccess, Error> {
        SYDataResponse<NewSuccess, Error>(response: response, isDataFromCache: isDataFromCache, result: result.tryMap(transform))
        
    }

    /// Evaluates the specified closure when the `SYDataResponse` is a failure, passing the unwrapped error as a parameter.
    ///
    /// Use the `mapError` function with a closure that does not throw. For example:
    ///
    ///     let possibleData: SYDataResponse<Data> = ...
    ///     let withMyError = possibleData.mapError { MyError.error($0) }
    ///
    /// - Parameter transform: A closure that takes the error of the instance.
    ///
    /// - Returns: A `SYDataResponse` instance containing the result of the transform.
    public func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> SYDataResponse<Success, NewFailure> {
        SYDataResponse<Success, NewFailure>(response: response, isDataFromCache: isDataFromCache, result: result.mapError(transform))
    }

    /// Evaluates the specified closure when the `SYDataResponse` is a failure, passing the unwrapped error as a parameter.
    ///
    /// Use the `tryMapError` function with a closure that may throw an error. For example:
    ///
    ///     let possibleData: SYDataResponse<Data> = ...
    ///     let possibleObject = possibleData.tryMapError {
    ///         try someFailableFunction(taking: $0)
    ///     }
    ///
    /// - Parameter transform: A throwing closure that takes the error of the instance.
    ///
    /// - Returns: A `SYDataResponse` instance containing the result of the transform.
    public func tryMapError<NewFailure: Error>(_ transform: (Failure) throws -> NewFailure) -> SYDataResponse<Success, Error> {
        SYDataResponse<Success, Error>(response: response, isDataFromCache: isDataFromCache, result: result.tryMapError(transform))
    }
}
