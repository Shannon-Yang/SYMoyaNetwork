//
//  HTTPBinDynamicData.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2023/10/30.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SYMoyaNetwork

enum HTTPBinDynamicData: SYTargetType {
    case getDelay(delay: Int)
    case postDelay(delay: Int)
    case uuid
    case stream(n: Int)
    
    var baseURL: URL {
        URL(string: "http://httpbin.org")!
    }
    
    var path: String {
        switch self {
        case .getDelay(let delay):
            return "/delay/\(delay)"
        case .postDelay(let delay):
            return "/delay/\(delay)"
        case .uuid:
            return "/uuid"
        case .stream(let n):
            return "/stream/\(n)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getDelay:
            return .get
        case .postDelay:
            return .post
        case .uuid:
            return .get
        case .stream:
            return .get
        }
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
  
}
