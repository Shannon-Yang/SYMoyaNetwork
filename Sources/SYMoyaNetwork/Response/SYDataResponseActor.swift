//
//  SYDataResponseActor.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/5/26.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

/// An actor wrapping SYMoyaProvider
///
/// This actor is mainly used for `SYMoyaProvider` to implement `Concurrency/Task`
public actor SYDataResponseActor<Target: SYTargetType> {
    /// Protocol to define the opaque type returned from a request.
    public var cancellable: Moya.Cancellable?

    /// A request provider class that inherits from MoyaProvider. Requests can only be made through this class.
    public let provider: SYMoyaProvider<Target>

    /// Init `SYDataResponseActor`
    /// - Parameter provider: A request provider class that inherits from MoyaProvider. Requests can only be made through this class.
    public init(provider: SYMoyaProvider<Target>) {
        self.provider = provider
    }

    /// Cancels the represented request.
    public func cancel() {
        cancellable?.cancel()
    }
}

// MARK: - Response

extension SYDataResponseActor {
    /// A data request method, depending on the data request strategy. and parses the requested data into an object that is `SwiftyJSON.JSON`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `SwiftyJSON.JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    func responseSwiftyJSON(_ type: ResponseDataSourceType = .server, target: Target, serializer: SwiftyJSONResponseSerializer = .defaultSwiftyJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<SwiftyJSON.JSON>) -> Void) {
        cancellable = provider.responseSwiftyJSON(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: { dataResponse in
            completion(dataResponse)
        })
    }

    /// A data request method, depending on the data request strategy. and parses the requested data into an object that is `JSON`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `JSON`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    func responseJSON(_ type: ResponseDataSourceType = .server, target: Target, serializer: JSONResponseSerializer = .defaultJSONSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Any>) -> Void) {
        cancellable = provider.responseJSON(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }

    /// A data request method, depending on the data request strategy. and parses the requested data into an object that is `String`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `String`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    func responseString(_ type: ResponseDataSourceType = .server, target: Target, serializer: StringResponseSerializer = .defaultStringSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (SYMoyaNetworkDataResponse<String>) -> Void) {
        cancellable = provider.responseString(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }

    /// A data request method, depending on the data request strategy. and parses the requested data into an object that is `Image`.
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Image`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    func responseImage(_ type: ResponseDataSourceType = .server, target: Target, serializer: ImageResponseSerializer = .defaultImageSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @Sendable @escaping (_ dataResponse: SYMoyaNetworkDataResponse<Image>) -> Void) {
        cancellable = provider.responseImage(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }

    /// A data request method, depending on the data request strategy. and parses the requested data into an object that implements `Decodable`
    ///
    /// Data request strategy `ResponseDataSourceType` supports 5 types of data request strategys. This method performs data retrieval based on the strategy of `ResponseDataSourceType`.
    ///
    ///  It may retrieve data from cache (memory cache or disk), or by requesting data from the server. refer to the description of ``ResponseDataSourceType``.
    ///
    /// - Parameters:
    ///   - type: A data request strategy type. Default is `.server`
    ///   - target: The protocol used to define the specifications necessary for a `SYMoyaProvider`.
    ///   - serializer: A `ResponseSerializer` that decodes the response data as a `Decodable`.
    ///   - callbackQueue: The callback queue on which `completion` is invoked. Default is nil
    ///   - progress: Closure to be executed when progress changes.
    ///   - completion: A closure which is invoked when the request operation finishes. If not specified, the main queue will be used.
    func responseDecodableObject<T: Decodable>(_ type: ResponseDataSourceType = .server, target: Target, serializer: DecodableResponseSerializer<T> = .defaultDecodableSerializer, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping (_ dataResponse: SYMoyaNetworkDataResponse<T>) -> Void) {
        cancellable = provider.responseDecodableObject(type, target: target, serializer: serializer, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
}
