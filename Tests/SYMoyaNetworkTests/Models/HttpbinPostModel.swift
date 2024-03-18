//
//  HttpbinPostModel.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/30.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import ObjectMapper

class HttpbinPostModel: BaseMappable {
    var args: Any?
    var data: Any?
    var form: Any?
    var headers: HttpbinPostHeadersModel?
    var json: Any?
    var origin: String?
    var url: String?
    
    func mapping(map: ObjectMapper.Map) {
        args <- map["args"]
        data <- map["data"]
        form <- map["form"]
        headers <- map["headers"]
        json <- map["json"]
        origin <- map["origin"]
        url <- map["url"]
    }
}

class HttpbinPostHeadersModel: BaseMappable {
    var accept: String?
    var acceptEncoding: String?
    var acceptLanguage: String?
    var contentLength: Int = 0
    var host: String?
    var origin: String?
    var referer: String?
    var secFetchDest: String?
    var secFetchMode: String?
    var secFetchSite: String?
    var userAgent: String?
    
    func mapping(map: ObjectMapper.Map) {
        accept <- map["Accept"]
        acceptEncoding <- map["Accept-Encoding"]
        acceptLanguage <- map["Accept-Language"]
        contentLength <- map["Content-Length"]
        host <- map["Host"]
        origin <- map["Origin"]
        referer <- map["Referer"]
        secFetchDest <- map["Sec-Fetch-Dest"]
        secFetchMode <- map["Sec-Fetch-Mode"]
        secFetchSite <- map["Sec-Fetch-Site"]
        userAgent <- map["User-Agent"]
    }
}
