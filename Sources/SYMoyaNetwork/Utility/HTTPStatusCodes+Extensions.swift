//
//  HTTPStatusCodes+Extensions.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2022/1/8.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

extension HTTPStatusCode {
    /// Informational - Request received, continuing process.
    public var isInformational: Bool {
        isIn(range: 100...199)
    }

    /// Success - The action was successfully received, understood, and accepted.
    public var isSuccess: Bool {
        isIn(range: 200...299)
    }

    /// Redirection - Further action must be taken in order to complete the request.
    public var isRedirection: Bool {
        isIn(range: 300...399)
    }

    /// Client Error - The request contains bad syntax or cannot be fulfilled.
    public var isClientError: Bool {
        isIn(range: 400...499)
    }

    /// Server Error - The server failed to fulfill an apparently valid request.
    public var isServerError: Bool {
        isIn(range: 500...599)
    }

    /// - returns: `true` if the status code is in the provided range, false otherwise.
    private func isIn(range: ClosedRange<HTTPStatusCode.RawValue>) -> Bool {
        range.contains(rawValue)
    }
}

extension HTTPStatusCode {
    /// - returns: a localized string suitable for displaying to users that describes the specified status code.
    public var localizedReasonPhrase: String {
        HTTPURLResponse.localizedString(forStatusCode: rawValue)
    }
}

// MARK: - Printing

extension HTTPStatusCode: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        "\(rawValue) - \(localizedReasonPhrase)"
    }

    public var debugDescription: String {
        "HTTPStatusCode:\(description)"
    }
}

// MARK: - HTTP URL Response

extension HTTPStatusCode {
    /// Obtains a possible status code from an optional HTTP URL response.
    public init?(HTTPResponse: HTTPURLResponse?) {
        guard let statusCodeValue = HTTPResponse?.statusCode else {
            return nil
        }
        self.init(statusCodeValue)
    }

    /// This is declared as it's not automatically picked up by the complier for the above init
    private init?(_ rawValue: Int) {
        guard let value = HTTPStatusCode(rawValue: rawValue) else {
            return nil
        }
        self = value
    }
}

extension HTTPURLResponse {
    /**
     * Marked internal to expose (as `statusCodeValue`) for Objective-C interoperability only.
     *
     * - returns: the receiver’s HTTP status code.
     */
    @objc(statusCodeValue) public var statusCodeEnum: HTTPStatusCode {
        HTTPStatusCode(HTTPResponse: self)!
    }

    /// - returns: the receiver’s HTTP status code.
    public var statusCodeValue: HTTPStatusCode? {
        HTTPStatusCode(HTTPResponse: self)
    }

    /**
     * Initializer for NSHTTPURLResponse objects.
     *
     * - parameter url: the URL from which the response was generated.
     * - parameter statusCode: an HTTP status code.
     * - parameter HTTPVersion: the version of the HTTP response as represented by the server. This is typically represented as "HTTP/1.1".
     * - parameter headerFields: a dictionary representing the header keys and values of the server response.
     *
     * - returns: the instance of the object, or `nil` if an error occurred during initialization.
     */
    @available(iOS, introduced: 7.0)
    @objc(initWithURL:statusCodeValue:HTTPVersion:headerFields:)
    public convenience init?(url: URL, statusCode: HTTPStatusCode, httpVersion: String?, headerFields: [String: String]?) {
        self.init(url: url, statusCode: statusCode.rawValue, httpVersion: httpVersion, headerFields: headerFields)
    }
}
