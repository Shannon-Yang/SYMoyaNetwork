//
//  HttpbinPostHandyJSONModel.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/15.
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
        mapper <<< self.accept <-- "Accept"
        mapper <<< self.acceptEncoding <-- "Accept-Encoding"
        mapper <<< self.acceptLanguage <-- "Accept-Language"
        mapper <<< self.host <-- "Host"
        mapper <<< self.userAgent <-- "User-Agent"
        mapper <<< self.traceId <-- "X-Amzn-Trace-Id"
    }
}



