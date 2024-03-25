//
//  SYTargetType.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/7/14.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

/// The protocol used to define the specifications necessary for a `SYMoyaProvider`.
/// Inherit Moya.TargetType, extend more properties that can be set for TargetType, and add network cache type settings
public protocol SYTargetType: Moya.TargetType {
    /// CDN request url
    var cdnURL: URL? { get }

    ///  Should use CDN when sending request.
    var useCDN: Bool { get }

    /// The cache policy of the receiver.
    var cachePolicy: URLRequest.CachePolicy { get }

    /// Returns the timeout interval of the receiver.
    /// - discussion: The timeout interval specifies the limit on the idle
    /// interval allotted to a request in the process of loading. The "idle
    /// interval" is defined as the period of time that has passed since the
    /// last instance of load activity occurred for a request that is in the
    /// process of loading. Hence, when an instance of load activity occurs
    /// (e.g. bytes are received from the network for a request), the idle
    /// interval for a request is reset to 0. If the idle interval ever
    /// becomes greater than or equal to the timeout interval, the request
    /// is considered to have timed out. This timeout interval is measured
    /// in seconds.
    var timeoutInterval: TimeInterval { get }

    /// The main document URL associated with this load.
    /// - discussion: This URL is used for the cookie "same domain as main
    /// document" policy.
    var mainDocumentURL: URL? { get }

    /// The URLRequest.NetworkServiceType associated with this request.
    /// - discussion: This will return URLRequest.NetworkServiceType.default for requests that have
    /// not explicitly set a networkServiceType
    var networkServiceType: URLRequest.NetworkServiceType { get }

    /// `true` if the receiver is allowed to use the built in cellular radios to
    /// satisfy the request, `false` otherwise.
    var allowsCellularAccess: Bool { get }

    /// `true` if the receiver is allowed to use an interface marked as expensive to
    /// satify the request, `false` otherwise.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    var allowsExpensiveNetworkAccess: Bool { get }

    /// `true` if the receiver is allowed to use an interface marked as constrained to
    /// satify the request, `false` otherwise.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    var allowsConstrainedNetworkAccess: Bool { get }

    /// `true` if server endpoint is known to support HTTP/3. Enables QUIC racing
    /// without HTTP/3 service discovery. Defaults to `false`.
    /// The default may be `true` in a future OS update.
    @available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *)
    var assumesHTTP3Capable: Bool { get }

    /// `true` if cookies will be sent with and set for this request; otherwise `false`.
    var httpShouldHandleCookies: Bool { get }

    /// `true` if the receiver should transmit before the previous response
    /// is received. `false` if the receiver should wait for the previous response
    /// before transmitting.
    var httpShouldUsePipelining: Bool { get }

    /// Network Cache type of a cached Request.
    var networkCacheType: NetworkCacheType { get }
}

// MARK: - Default Value

extension SYTargetType {
    public var method: Moya.Method {
        .post
    }

    public var cdnURL: URL? {
        nil
    }

    public var useCDN: Bool {
        false
    }

    public var cachePolicy: URLRequest.CachePolicy {
        .reloadIgnoringCacheData
    }

    public var timeoutInterval: TimeInterval {
        60
    }

    public var mainDocumentURL: URL? {
        nil
    }

    public var networkServiceType: URLRequest.NetworkServiceType {
        .default
    }

    public var allowsCellularAccess: Bool {
        true
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public var allowsExpensiveNetworkAccess: Bool {
        true
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public var allowsConstrainedNetworkAccess: Bool {
        true
    }

    @available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *)
    public var assumesHTTP3Capable: Bool {
        true
    }

    public var httpShouldHandleCookies: Bool {
        true
    }

    public var httpShouldUsePipelining: Bool {
        true
    }

    public var networkCacheType: NetworkCacheType {
        .none
    }

    public var validationType: ValidationType {
        .successCodes
    }
}

// MARK: - Internal

extension SYTargetType {
    func requestBaseURL() -> URL {
        if useCDN {
            if let cdnURL {
                return cdnURL
            }
            return baseURL
        }
        return baseURL
    }
}
