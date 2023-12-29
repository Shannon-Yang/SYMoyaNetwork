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
