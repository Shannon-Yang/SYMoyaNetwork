//
//  HTTPVersion.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/12/29.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

/// Version number of the HTTP Protocol
public struct HTTPVersion {
    /// Major version component.
    public private(set) var major: Int
    /// Minor version component.
    public private(set) var minor: Int

    /// Creates an HTTP version.
    public init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }

    /// HTTP/0.9
    static let http0_9 = Self(major: 0, minor: 9)
    /// HTTP/1.0
    static let http1_0 = Self(major: 1, minor: 0)
    /// HTTP/1.1
    static let http1_1 = Self(major: 1, minor: 1)
    /// HTTP/2.0
    static let http2 = Self(major: 2, minor: 0)
    /// HTTP/3.0
    static let http3 = Self(major: 3, minor: 0)
}

extension HTTPVersion: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
}

extension HTTPVersion {
    /// :nodoc:
    public static func == (lhs: HTTPVersion, rhs: HTTPVersion) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor
    }

    /// :nodoc:
    public static func ~= (match: HTTPVersion, version: HTTPVersion) -> Bool {
        match == version
    }
}

extension HTTPVersion: Comparable {
    /// :nodoc:
    public static func < (lhs: HTTPVersion, rhs: HTTPVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else {
            return lhs.minor < rhs.minor
        }
    }
}

extension HTTPVersion: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        "HTTP/\(major).\(minor)"
    }
}
