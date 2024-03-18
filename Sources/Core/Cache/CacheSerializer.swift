//
//  CacheSerializer.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/7/14.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// An `CacheSerializer` is used to convert some data to an response object after
/// retrieving it from disk storage, and vice versa, to convert an response to data object
/// for storing to the disk storage.
public protocol CacheSerializer {
    
    /// Gets the serialized data from a provided response
    /// and optional original data for caching to disk.
    ///
    /// - Parameters:
    ///   - response: The response needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the response is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    func data(with response: Moya.Response) -> Data

    /// Gets an response from provided serialized data.
    ///
    /// - Parameters:
    ///   - data: The data from which an response should be deserialized.
    ///   - options: The parsed options for deserialization.
    /// - Returns: An response deserialized or `nil` when no valid response
    ///            could be deserialized.
    func response(with statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?, options: SYMoyaNetworkParsedOptionsInfo) -> Moya.Response
}

/// Represents a basic and default `CacheSerializer` used in SYMoyaNetwork disk cache system.
/// It could serialize and deserialize response For
/// response other than these formats, a normalized `pngRepresentation` will be used.
public struct DefaultCacheSerializer: CacheSerializer {
    
    /// The default general cache serializer used across SYMoyaNetwork's cache.
    public static let `default` = DefaultCacheSerializer()

    /// Creates a cache serializer that serialize and deserialize response
    ///
    /// - Note:
    /// Use `DefaultCacheSerializer.default` unless you need to specify your own properties.
    ///
    public init() { }

    /// - Parameters:
    ///   - response: The response needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the response is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    ///
    /// - Note:
    /// converted to the corresponding data type. Otherwise, if the `original` is provided but it is not
    /// If `original` is `nil`, the input `response` will be encoded as  data.
    public func data(with response: Moya.Response) -> Data {
        return response.data
    }
    
    /// Gets an response deserialized from provided data.
    ///
    /// - Parameters:
    ///   - data: The data from which an response should be deserialized.
    ///   - options: Options for deserialization.
    /// - Returns: An response deserialized or `nil` when no valid response
    ///            could be deserialized.
    public func response(with statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?, options: SYMoyaNetworkParsedOptionsInfo) -> Moya.Response {
        let response = Moya.Response(statusCode: statusCode, data: data, request: request, response: response)
        return response
    }
}
