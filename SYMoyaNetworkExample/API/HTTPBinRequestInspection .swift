//
//  HTTPBinRequestInspection .swift
//  SYMoyaNetworkTests
//
//  Created by Shannon Yang on 2023/10/30.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya
import SYMoyaNetwork

enum HTTPBinRequestInspection: SYTargetType {
    case headers
    case ip
    case userAgent

    var baseURL: URL {
        URL(string: "http://httpbin.org")!
    }

    var path: String {
        switch self {
        case .headers:
            return "/headers"
        case .ip:
            return "/ip"
        case .userAgent:
            return "/user-agent"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Moya.Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return nil
    }
}
