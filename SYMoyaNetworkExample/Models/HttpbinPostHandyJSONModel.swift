//
//  HttpbinPostHandyJSONModel.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/15.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import HandyJSON

class HttpbinPostHandyJSONModel: HandyJSON, CustomStringConvertible {
    var headers: HttpbinPostHeaderHandyJSONModel?
    var origin: String?
    var url: String?
    required init() {}

    var description: String {
        return "headers: \n {\n\(headers?.description ?? "")\n} \n origin:\(origin ?? "")\n, \n url:\(url ?? "")"
    }
}

class HttpbinPostHeaderHandyJSONModel: HandyJSON, CustomStringConvertible {
    var accept: String?
    var acceptEncoding: String?
    var acceptLanguage: String?
    var host: String?
    var userAgent: String?
    var traceId: String?

    required init() {}

    var description: String {
        return "accept: \(accept ?? ""), \n acceptEncoding: \(acceptEncoding ?? ""), \n acceptLanguage: \(acceptLanguage ?? ""),\n host: \(host ?? ""), \n userAgent: \(userAgent ?? "")"
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< accept <-- "Accept"
        mapper <<< acceptEncoding <-- "Accept-Encoding"
        mapper <<< acceptLanguage <-- "Accept-Language"
        mapper <<< host <-- "Host"
        mapper <<< userAgent <-- "User-Agent"
        mapper <<< traceId <-- "X-Amzn-Trace-Id"
    }
}
