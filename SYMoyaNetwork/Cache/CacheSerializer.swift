//
//  CacheSerializer.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/7/14.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// An `CacheSerializer` is used to convert some data to an image object after
/// retrieving it from disk storage, and vice versa, to convert an image to data object
/// for storing to the disk storage.
public protocol CacheSerializer {
    
    /// Gets the serialized data from a provided image
    /// and optional original data for caching to disk.
    ///
    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    func data(with response: Moya.Response) -> Data

    /// Gets an image from provided serialized data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: The parsed options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    func response(with statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?, options: SYMoyaNetworkParsedOptionsInfo) -> Moya.Response
}

/// Represents a basic and default `CacheSerializer` used in Kingfisher disk cache system.
/// It could serialize and deserialize images in PNG, JPEG and GIF format. For
/// image other than these formats, a normalized `pngRepresentation` will be used.
public struct DefaultCacheSerializer: CacheSerializer {
    
    /// The default general cache serializer used across Kingfisher's cache.
    public static let `default` = DefaultCacheSerializer()

    /// Creates a cache serializer that serialize and deserialize images in PNG, JPEG and GIF format.
    ///
    /// - Note:
    /// Use `DefaultCacheSerializer.default` unless you need to specify your own properties.
    ///
    public init() { }

    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    ///
    /// - Note:
    /// Only when `original` contains valid PNG, JPEG and GIF format data, the `image` will be
    /// converted to the corresponding data type. Otherwise, if the `original` is provided but it is not
    /// If `original` is `nil`, the input `image` will be encoded as PNG data.
    public func data(with response: Moya.Response) -> Data {
        return response.data
    }
    
    /// Gets an image deserialized from provided data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: Options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    public func response(with statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?, options: SYMoyaNetworkParsedOptionsInfo) -> Moya.Response {
        let response = Moya.Response(statusCode: statusCode, data: data, request: request, response: response)
        return response
    }
}
