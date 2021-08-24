//
//  SYMoyaTargetType.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/7/14.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

public protocol TargetType: Moya.TargetType {

    var cdnURL: URL? { get }
    
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
    @available(macOS 10.7, iOS 4.0, *)
    var networkServiceType: URLRequest.NetworkServiceType { get }

    /// `true` if the receiver is allowed to use the built in cellular radios to
    /// satisfy the request, `false` otherwise.
    @available(macOS 10.8, iOS 6.0, *)
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
    
    /**
        @abstract Determine whether default cookie handling will happen for
        this request.
        @discussion NOTE: This value is not used prior to 10.3
        @result YES if cookies will be sent with and set for this request;
        otherwise NO.
    */
    var httpShouldHandleCookies: Bool { get }
    
    /**
     @abstract Reports whether the receiver is not expected to wait for the
     previous response before transmitting.
     @result YES if the receiver should transmit before the previous response
     is received.  NO if the receiver should wait for the previous response
     before transmitting.
     */
    @available(iOS 4.0, *)
    var httpShouldUsePipelining: Bool { get }
}

public extension TargetType {
    
    var cdnURL: URL? {
        return nil
    }
    
    var useCDN: Bool {
        return false
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringCacheData
    }

    var timeoutInterval: TimeInterval {
        return 60
    }

    var mainDocumentURL: URL? {
       return nil
    }

    @available(macOS 10.7, iOS 4.0, *)
    var networkServiceType: URLRequest.NetworkServiceType {
        return .default
    }

    @available(macOS 10.8, iOS 6.0, *)
    var allowsCellularAccess: Bool {
        return true
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    var allowsExpensiveNetworkAccess: Bool {
        return true
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    var allowsConstrainedNetworkAccess: Bool {
        return true
    }

    @available(macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, *)
    var assumesHTTP3Capable: Bool {
        return true
    }
    
    var httpShouldHandleCookies: Bool {
        return true
    }
    
    var httpShouldUsePipelining: Bool {
        return true
    }
}

