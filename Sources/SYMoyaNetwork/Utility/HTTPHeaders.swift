//
//  HTTPHeaders.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/12/29.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

/// Representation of the HTTP headers associated with a `HTTPRequest` or `HTTPResponse`.
/// Headers are subscriptable using case-insensitive comparison or provide `Name` constants. eg.
/// ```swift
///    let contentLength = headers["content-length"]
/// ```
/// or
/// ```swift
///    let contentLength = headers[.contentLength]
/// ```
public struct HTTPHeaders {
    var original: [(name: Name, value: String)]?
    var storage: [Name: [String]] {
        didSet { original = nil }
    }

    /// :nodoc:
    public subscript(name: Name) -> String? {
        get {
            guard let value = storage[name] else {
                return nil
            }
            switch name {
            case Name.setCookie: // Exception, see note in [RFC7230, section 3.2.2]
                return value.isEmpty ? nil : value[0]
            default:
                return value.joined(separator: ",")
            }
        }
        set {
            storage[name] = newValue.map { [$0] }
        }
    }

    /// :nodoc:
    public subscript(valuesFor name: Name) -> [String] {
        get { storage[name] ?? [] }
        set { storage[name] = newValue.isEmpty ? nil : newValue }
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    /// Creates HTTP headers.
    public init(dictionaryLiteral: (Name, String)...) {
        storage = [:]
        for (name, value) in dictionaryLiteral {
            storage[name, default: []].append(value)
        }
        original = dictionaryLiteral
    }
}

extension HTTPHeaders {
    // Used instead of HTTPHeaders to save CPU on dictionary construction
    /// :nodoc:
    public struct Literal: ExpressibleByDictionaryLiteral {
        let fields: [(name: Name, value: String)]

        public init(dictionaryLiteral: (Name, String)...) {
            fields = dictionaryLiteral
        }
    }

    /// Appends a header to the headers
    public mutating func append(_ literal: HTTPHeaders.Literal) {
        for (name, value) in literal.fields {
            storage[name, default: []].append(value)
        }
    }

    /// Replaces a header in the headers
    public mutating func replace(_ literal: HTTPHeaders.Literal) {
        for (name, _) in literal.fields {
            storage[name] = []
        }
        for (name, value) in literal.fields {
            if var name = storage[name] {
                name.append(value)
            }
        }
    }
}

extension HTTPHeaders: Sequence {
    /// :nodoc:
    public func makeIterator() -> AnyIterator<(name: Name, value: String)> {
        if let original {
            return AnyIterator(original.makeIterator())
        } else {
            return AnyIterator(StorageIterator(storage.makeIterator()))
        }
    }

    struct StorageIterator: IteratorProtocol {
        var headers: DictionaryIterator<Name, [String]>
        var header: (name: Name, values: IndexingIterator<[String]>)?

        init(_ iterator: DictionaryIterator<Name, [String]>) {
            headers = iterator
            header = headers.next().map { (name: $0.key, values: $0.value.makeIterator()) }
        }

        mutating func next() -> (name: Name, value: String)? {
            while header != nil {
                if var values = header?.values {
                    if let value = values.next() {
                        guard let name = header?.name else {
                            fatalError("Header name can't is nil")
                        }
                        return (name: name, value: value)
                    } else {
                        header = headers.next().map { (name: $0.key, values: $0.value.makeIterator()) }
                    }
                }
            }
            return nil
        }
    }
}

/// HTTPHeaders structure.
extension HTTPHeaders {
    /// Type used for the name of a HTTP header in the `HTTPHeaders` storage.
    public struct Name: Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
        let original: String
        let lowercased: String
        public let hashValue: Int

        /// Create a HTTP header name with the provided String.
        public init(_ name: String) {
            original = name
            lowercased = name.lowercased()
            hashValue = lowercased.hashValue
        }

        public init(stringLiteral: String) {
            self.init(stringLiteral)
        }

        public init(unicodeScalarLiteral: String) {
            self.init(unicodeScalarLiteral)
        }

        public init(extendedGraphemeClusterLiteral: String) {
            self.init(extendedGraphemeClusterLiteral)
        }

        /// :nodoc:
        public var description: String {
            original
        }

        /// :nodoc:
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.lowercased == rhs.lowercased
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(hashValue)
        }

        // https://www.iana.org/assignments/message-headers/message-headers.xhtml
        // Permanent Message Header Field Names

        /// A-IM header.
        public static let aIM = Self("A-IM")
        /// Accept header.
        public static let accept = Self("Accept")
        /// Accept-Additions header.
        public static let acceptAdditions = Self("Accept-Additions")
        /// Accept-Charset header.
        public static let acceptCharset = Self("Accept-Charset")
        /// Accept-Datetime header.
        public static let acceptDatetime = Self("Accept-Datetime")
        /// Accept-Encoding header.
        public static let acceptEncoding = Self("Accept-Encoding")
        /// Accept-Features header.
        public static let acceptFeatures = Self("Accept-Features")
        /// Accept-Language header.
        public static let acceptLanguage = Self("Accept-Language")
        /// Accept-Patch header.
        public static let acceptPatch = Self("Accept-Patch")
        /// Accept-Post header.
        public static let acceptPost = Self("Accept-Post")
        /// Accept-Ranges header.
        public static let acceptRanges = Self("Accept-Ranges")
        /// Accept-Age header.
        public static let age = Self("Age")
        /// Accept-Allow header.
        public static let allow = Self("Allow")
        /// ALPN header.
        public static let alpn = Self("ALPN")
        /// Alt-Svc header.
        public static let altSvc = Self("Alt-Svc")
        /// Alt-Used header.
        public static let altUsed = Self("Alt-Used")
        /// Alternatives header.
        public static let alternates = Self("Alternates")
        /// Apply-To-Redirect-Ref header.
        public static let applyToRedirectRef = Self("Apply-To-Redirect-Ref")
        /// Authentication-Control header.
        public static let authenticationControl = Self("Authentication-Control")
        /// Authentication-Info header.
        public static let authenticationInfo = Self("Authentication-Info")
        /// Authorization header.
        public static let authorization = Self("Authorization")
        /// C-Ext header.
        public static let cExt = Self("C-Ext")
        /// C-Man header.
        public static let cMan = Self("C-Man")
        /// C-Opt header.
        public static let cOpt = Self("C-Opt")
        /// C-PEP header.
        public static let cPEP = Self("C-PEP")
        /// C-PEP-Indo header.
        public static let cPEPInfo = Self("C-PEP-Info")
        /// Cache-Control header.
        public static let cacheControl = Self("Cache-Control")
        /// CalDav-Timezones header.
        public static let calDAVTimezones = Self("CalDAV-Timezones")
        /// Close header.
        public static let close = Self("Close")
        /// Connection header.
        public static let connection = Self("Connection")
        /// Content-Base.
        public static let contentBase = Self("Content-Base")
        /// Content-Disposition header.
        public static let contentDisposition = Self("Content-Disposition")
        /// Content-Encoding header.
        public static let contentEncoding = Self("Content-Encoding")
        /// Content-ID header.
        public static let contentID = Self("Content-ID")
        /// Content-Language header.
        public static let contentLanguage = Self("Content-Language")
        /// Content-Length header.
        public static let contentLength = Self("Content-Length")
        /// Content-Location header.
        public static let contentLocation = Self("Content-Location")
        /// Content-MD5 header.
        public static let contentMD5 = Self("Content-MD5")
        /// Content-Range header.
        public static let contentRange = Self("Content-Range")
        /// Content-Script-Type header.
        public static let contentScriptType = Self("Content-Script-Type")
        /// Content-Style-Type header.
        public static let contentStyleType = Self("Content-Style-Type")
        /// Content-Type header.
        public static let contentType = Self("Content-Type")
        /// Content-Version header.
        public static let contentVersion = Self("Content-Version")
        /// Content-Cookie header.
        public static let cookie = Self("Cookie")
        /// Content-Cookie2 header.
        public static let cookie2 = Self("Cookie2")
        /// DASL header.
        public static let dasl = Self("DASL")
        /// DASV header.
        public static let dav = Self("DAV")
        /// Date header.
        public static let date = Self("Date")
        /// Default-Style header.
        public static let defaultStyle = Self("Default-Style")
        /// Delta-Base header.
        public static let deltaBase = Self("Delta-Base")
        /// Depth header.
        public static let depth = Self("Depth")
        /// Derived-From header.
        public static let derivedFrom = Self("Derived-From")
        /// Destination header.
        public static let destination = Self("Destination")
        /// Differential-ID header.
        public static let differentialID = Self("Differential-ID")
        /// Digest header.
        public static let digest = Self("Digest")
        /// ETag header.
        public static let eTag = Self("ETag")
        /// Expect header.
        public static let expect = Self("Expect")
        /// Expires header.
        public static let expires = Self("Expires")
        /// Ext header.
        public static let ext = Self("Ext")
        /// Forwarded header.
        public static let forwarded = Self("Forwarded")
        /// From header.
        public static let from = Self("From")
        /// GetProfile header.
        public static let getProfile = Self("GetProfile")
        /// Hobareg header.
        public static let hobareg = Self("Hobareg")
        /// Host header.
        public static let host = Self("Host")
        /// HTTP2-Settings header.
        public static let http2Settings = Self("HTTP2-Settings")
        /// IM header.
        public static let im = Self("IM")
        /// If header.
        public static let `if` = Self("If")
        /// If-Match header.
        public static let ifMatch = Self("If-Match")
        /// If-Modified-Since header.
        public static let ifModifiedSince = Self("If-Modified-Since")
        /// If-None-Match header.
        public static let ifNoneMatch = Self("If-None-Match")
        /// If-Range header.
        public static let ifRange = Self("If-Range")
        /// If-Schedule-Tag-Match header.
        public static let ifScheduleTagMatch = Self("If-Schedule-Tag-Match")
        /// If-Unmodified-Since header.
        public static let ifUnmodifiedSince = Self("If-Unmodified-Since")
        /// Keep-Alive header.
        public static let keepAlive = Self("Keep-Alive")
        /// Label header.
        public static let label = Self("Label")
        /// Last-Modified header.
        public static let lastModified = Self("Last-Modified")
        /// Link header.
        public static let link = Self("Link")
        /// Location header.
        public static let location = Self("Location")
        /// Lock-Token header.
        public static let lockToken = Self("Lock-Token")
        /// Man header.
        public static let man = Self("Man")
        /// Max-Forwards header.
        public static let maxForwards = Self("Max-Forwards")
        /// Memento-Date header.
        public static let mementoDatetime = Self("Memento-Datetime")
        /// Meter header.
        public static let meter = Self("Meter")
        /// MIME-Version header.
        public static let mimeVersion = Self("MIME-Version")
        /// Negotiate header.
        public static let negotiate = Self("Negotiate")
        /// Opt header.
        public static let opt = Self("Opt")
        /// Optional-WWW-Authenticate header.
        public static let optionalWWWAuthenticate = Self("Optional-WWW-Authenticate")
        /// Ordering-Type header.
        public static let orderingType = Self("Ordering-Type")
        /// Origin header.
        public static let origin = Self("Origin")
        /// Overwrite header.
        public static let overwrite = Self("Overwrite")
        /// P3P header.
        public static let p3p = Self("P3P")
        /// PEP header.
        public static let pep = Self("PEP")
        /// PICS-Label header.
        public static let picsLabel = Self("PICS-Label")
        /// Pep-Info header.
        public static let pepInfo = Self("Pep-Info")
        /// Position header.
        public static let position = Self("Position")
        /// Pragma header.
        public static let pragma = Self("Pragma")
        /// Prefer header.
        public static let prefer = Self("Prefer")
        /// Preference-Applied header.
        public static let preferenceApplied = Self("Preference-Applied")
        /// ProfileObject header.
        public static let profileObject = Self("ProfileObject")
        /// Protocol header.
        public static let `protocol` = Self("Protocol")
        /// Protocol-Info header.
        public static let protocolInfo = Self("Protocol-Info")
        /// Protocol-Query header.
        public static let protocolQuery = Self("Protocol-Query")
        /// Protocol-Request header.
        public static let protocolRequest = Self("Protocol-Request")
        /// Proxy-Authenticate header.
        public static let proxyAuthenticate = Self("Proxy-Authenticate")
        /// Proxy-Authentication-Info header.
        public static let proxyAuthenticationInfo = Self("Proxy-Authentication-Info")
        /// Proxy-Authorization header.
        public static let proxyAuthorization = Self("Proxy-Authorization")
        /// Proxy-Features header.
        public static let proxyFeatures = Self("Proxy-Features")
        /// Proxy-Instruction header.
        public static let proxyInstruction = Self("Proxy-Instruction")
        /// Public header.
        public static let `public` = Self("Public")
        /// Public-Key-Pins header.
        public static let publicKeyPins = Self("Public-Key-Pins")
        /// Public-Key-Pins-Report-Only header.
        public static let publicKeyPinsReportOnly = Self("Public-Key-Pins-Report-Only")
        /// Range header.
        public static let range = Self("Range")
        /// Redirect-Ref header.
        public static let redirectRef = Self("Redirect-Ref")
        /// Referer header.
        public static let referer = Self("Referer")
        /// Retry-After header.
        public static let retryAfter = Self("Retry-After")
        /// Safe header.
        public static let safe = Self("Safe")
        /// Schedule-Reply header.
        public static let scheduleReply = Self("Schedule-Reply")
        /// Schedule-Tag header.
        public static let scheduleTag = Self("Schedule-Tag")
        /// Sec-WebSocket-Accept header.
        public static let secWebSocketAccept = Self("Sec-WebSocket-Accept")
        /// Sec-WebSocket-Extensions header.
        public static let secWebSocketExtensions = Self("Sec-WebSocket-Extensions")
        /// Sec-WebSocket-Key header.
        public static let secWebSocketKey = Self("Sec-WebSocket-Key")
        /// Sec-WebSocket-Protocol header.
        public static let secWebSocketProtocol = Self("Sec-WebSocket-Protocol")
        /// Sec-WebSocket-Version header.
        public static let secWebSocketVersion = Self("Sec-WebSocket-Version")
        /// Security-Scheme header.
        public static let securityScheme = Self("Security-Scheme")
        /// Server header.
        public static let server = Self("Server")
        /// Set-Cookie header.
        public static let setCookie = Self("Set-Cookie")
        /// Set-Cookie2 header.
        public static let setCookie2 = Self("Set-Cookie2")
        /// SetProfile header.
        public static let setProfile = Self("SetProfile")
        /// SLUG header.
        public static let slug = Self("SLUG")
        /// SoapAction header.
        public static let soapAction = Self("SoapAction")
        /// Status-URI header.
        public static let statusURI = Self("Status-URI")
        /// Strict-Transport-Security header.
        public static let strictTransportSecurity = Self("Strict-Transport-Security")
        /// Surrogate-Capability header.
        public static let surrogateCapability = Self("Surrogate-Capability")
        /// Surrogate-Control header.
        public static let surrogateControl = Self("Surrogate-Control")
        /// TCN header.
        public static let tcn = Self("TCN")
        /// TE header.
        public static let te = Self("TE")
        /// Timeout header.
        public static let timeout = Self("Timeout")
        /// Topic header.
        public static let topic = Self("Topic")
        /// Trailer header.
        public static let trailer = Self("Trailer")
        /// Transfer-Encoding header.
        public static let transferEncoding = Self("Transfer-Encoding")
        /// TTL header.
        public static let ttl = Self("TTL")
        /// Urgency header.
        public static let urgency = Self("Urgency")
        /// URI header.
        public static let uri = Self("URI")
        /// Upgrade header.
        public static let upgrade = Self("Upgrade")
        /// User-Agent header.
        public static let userAgent = Self("User-Agent")
        /// Variant-Vary header.
        public static let variantVary = Self("Variant-Vary")
        /// Vary header.
        public static let vary = Self("Vary")
        /// Via header.
        public static let via = Self("Via")
        /// WWW-Authenticate header.
        public static let wwwAuthenticate = Self("WWW-Authenticate")
        /// Want-Digest header.
        public static let wantDigest = Self("Want-Digest")
        /// Warning header.
        public static let warning = Self("Warning")
        /// X-Frame-Options header.
        public static let xFrameOptions = Self("X-Frame-Options")

        // https://www.iana.org/assignments/message-headers/message-headers.xhtml
        // Provisional Message Header Field Names
        /// Access-Control header.
        public static let accessControl = Self("Access-Control")
        /// Access-Control-Allow-Credentials header.
        public static let accessControlAllowCredentials = Self("Access-Control-Allow-Credentials")
        /// Access-Control-Allow-Headers header.
        public static let accessControlAllowHeaders = Self("Access-Control-Allow-Headers")
        /// Access-Control-Allow-Methods header.
        public static let accessControlAllowMethods = Self("Access-Control-Allow-Methods")
        /// Access-Control-Allow-Origin header.
        public static let accessControlAllowOrigin = Self("Access-Control-Allow-Origin")
        /// Access-Control-Max-Age header.
        public static let accessControlMaxAge = Self("Access-Control-Max-Age")
        /// Access-Control-Request-Method header.
        public static let accessControlRequestMethod = Self("Access-Control-Request-Method")
        /// Access-Control-Request-Headers header.
        public static let accessControlRequestHeaders = Self("Access-Control-Request-Headers")
        /// Compliance header.
        public static let compliance = Self("Compliance")
        /// Content-Transfer-Encoding header.
        public static let contentTransferEncoding = Self("Content-Transfer-Encoding")
        /// Cost header.
        public static let cost = Self("Cost")
        /// EDIINT-Features header.
        public static let ediintFeatures = Self("EDIINT-Features")
        /// Message-ID header.
        public static let messageID = Self("Message-ID")
        /// Method-Check header.
        public static let methodCheck = Self("Method-Check")
        /// Method-Check-Expires header.
        public static let methodCheckExpires = Self("Method-Check-Expires")
        /// Non-Compliance header.
        public static let nonCompliance = Self("Non-Compliance")
        /// Optional header.
        public static let optional = Self("Optional")
        /// Referer-Root header.
        public static let refererRoot = Self("Referer-Root")
        /// Resolution-Hint header.
        public static let resolutionHint = Self("Resolution-Hint")
        /// Resolver-Location header.
        public static let resolverLocation = Self("Resolver-Location")
        /// SubOK header.
        public static let subOK = Self("SubOK")
        /// Subst header.
        public static let subst = Self("Subst")
        /// Title header.
        public static let title = Self("Title")
        /// UA-Color header.
        public static let uaColor = Self("UA-Color")
        /// UA-Media header.
        public static let uaMedia = Self("UA-Media")
        /// UA-Pixels header.
        public static let uaPixels = Self("UA-Pixels")
        /// UA-Resolution header.
        public static let uaResolution = Self("UA-Resolution")
        /// UA-Windowpixels header.
        public static let uaWindowpixels = Self("UA-Windowpixels")
        /// Version header.
        public static let version = Self("Version")
        /// X-Device-Accept header.
        public static let xDeviceAccept = Self("X-Device-Accept")
        /// X-Device-Accept-Charset header.
        public static let xDeviceAcceptCharset = Self("X-Device-Accept-Charset")
        /// X-Device-Accept-Encoding header.
        public static let xDeviceAcceptEncoding = Self("X-Device-Accept-Encoding")
        /// X-Device-Accept-Language header.
        public static let xDeviceAcceptLanguage = Self("X-Device-Accept-Language")
        /// X-Device-User-Agent header.
        public static let xDeviceUserAgent = Self("X-Device-User-Agent")
    }
}
