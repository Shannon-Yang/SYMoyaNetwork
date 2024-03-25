//
//  HttpbinPostModel.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/30.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import ObjectMapper

class HttpbinPostObjectMapperModel: Mappable, CustomStringConvertible {
    required init?(map: ObjectMapper.Map) {
    }

    var headers: HttpbinPostHeaderObjectMapperModel?
    var origin: String?
    var url: String?

    func mapping(map: ObjectMapper.Map) {
        headers <- map["headers"]
        origin <- map["origin"]
        url <- map["url"]
    }

    var description: String {
        return "headers: \n {\n\(headers?.description ?? "")\n} \n origin:\(origin ?? "")\n, \n url:\(url ?? "")"
    }
}

class HttpbinPostHeaderObjectMapperModel: Mappable, CustomStringConvertible {
    var accept: String?
    var acceptEncoding: String?
    var acceptLanguage: String?
    var host: String?
    var userAgent: String?
    var traceId: String?

    required init?(map: ObjectMapper.Map) {
    }

    func mapping(map: ObjectMapper.Map) {
        accept <- map["Accept"]
        acceptEncoding <- map["Accept-Encoding"]
        acceptLanguage <- map["Accept-Language"]
        host <- map["Host"]
        userAgent <- map["User-Agent"]
        traceId <- map["X-Amzn-Trace-Id"]
    }

    var description: String {
        return "accept: \(accept ?? ""), \n acceptEncoding: \(acceptEncoding ?? ""), \n acceptLanguage: \(acceptLanguage ?? ""),\n host: \(host ?? ""), \n userAgent: \(userAgent ?? "")"
    }
}
