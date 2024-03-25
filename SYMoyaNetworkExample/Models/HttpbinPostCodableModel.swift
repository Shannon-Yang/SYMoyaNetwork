//
//  HttpbinPostCodableModel.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/13.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation

class HttpbinPostCodableModel: Codable {
    var url: String?
    var origin: String?

    var accept: String?
    var acceptEncoding: String?
    var acceptLanguage: String?
    var host: String?
    var userAgent: String?
    var traceId: String?

    enum CodingKeys: String, CodingKey {
        case headers
        case url
        case origin
    }

    enum HeaderCodingKeys: String, CodingKey {
        case accept = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case host = "Host"
        case userAgent = "User-Agent"
        case traceId = "X-Amzn-Trace-Id"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        origin = try container.decode(String?.self, forKey: .origin)

        let headersContainer = try container.nestedContainer(keyedBy: HeaderCodingKeys.self, forKey: .headers)
        accept = try headersContainer.decode(String?.self, forKey: .accept)
        acceptEncoding = try headersContainer.decode(String?.self, forKey: .acceptEncoding)
        acceptLanguage = try headersContainer.decode(String?.self, forKey: .acceptLanguage)

        host = try headersContainer.decode(String?.self, forKey: .host)
        userAgent = try headersContainer.decode(String?.self, forKey: .userAgent)
        traceId = try headersContainer.decode(String?.self, forKey: .traceId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(origin, forKey: .origin)

        var headersContainer = container.nestedContainer(keyedBy: HeaderCodingKeys.self, forKey: .headers)
        try headersContainer.encode(accept, forKey: .accept)
        try headersContainer.encode(acceptEncoding, forKey: .acceptEncoding)
        try headersContainer.encode(acceptLanguage, forKey: .acceptLanguage)

        try headersContainer.encode(host, forKey: .host)
        try headersContainer.encode(userAgent, forKey: .userAgent)
        try headersContainer.encode(traceId, forKey: .traceId)
    }

    var description: String {
        return "Accept: \(accept ?? ""), \n\nAcceptEncoding: \(acceptEncoding ?? ""), \n\nAcceptLanguage: \(acceptLanguage ?? ""), \n\nHost: \(host ?? ""), \n\nOrigin: \(origin ?? ""), \n\nUserAgent: \(userAgent ?? ""), \n\nTraceId: \(traceId ?? "")"
    }
}
