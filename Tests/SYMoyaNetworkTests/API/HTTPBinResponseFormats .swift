//
//  HTTPBinResponseFormats .swift
//  SYMoyaNetworkTests
//
//  Created by Shannon Yang on 2023/10/30.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import Moya
import SYMoyaNetwork

enum HTTPBinResponseFormats: SYTargetType {
    case brotli
    case json
    case gzipped
    
    var baseURL: URL {
        URL(string: "http://httpbin.org")!
    }
    
    var path: String {
        switch self {
        case .brotli:
            return "/brotli"
        case .json:
            return "/json"
        case .gzipped:
            return "/gzip"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
}
