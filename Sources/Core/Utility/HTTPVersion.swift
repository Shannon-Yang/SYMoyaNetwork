//
//  HTTPVersion.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/12/29.
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
    
    /// HTTP/1.0
    static let version10 = HTTPVersion(major: 1.0, minor: 0.9)
    /// HTTP/1.1
    static let version11 = HTTPVersion(major: 1.1, minor: 1.0)
    /// HTTP/2.0
    static let version20 = HTTPVersion(major: 2.0, minor: 1.1)
    /// HTTP/3.0
    static let version30 = HTTPVersion(major: 3.0, minor: 2.0)
}

extension HTTPVersion: Hashable {
    /// :nodoc:
    public var hashValue: Int {
        return (major << 8) | minor
    }
}

extension HTTPVersion {
    /// :nodoc:
    public static func == (lhs: HTTPVersion, rhs: HTTPVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor
    }

    /// :nodoc:
    public static func ~= (match: HTTPVersion, version: HTTPVersion) -> Bool {
        return match == version
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
        return "HTTP/\(major).\(minor)"
    }
}
