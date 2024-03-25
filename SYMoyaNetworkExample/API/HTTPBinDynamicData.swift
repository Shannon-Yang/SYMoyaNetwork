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
        case let .getDelay(delay):
            return "/delay/\(delay)"
        case let .postDelay(delay):
            return "/delay/\(delay)"
        case .uuid:
            return "/uuid"
        case let .stream(n):
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

    var headers: [String: String]? {
        return nil
    }

    var networkCacheType: NetworkCacheType {
        var info = NetworkCacheType.NetworkCacheOptionsInfo()
        // Set to expire after one day
        info.diskStorageConfig.expiration = .days(1)
        return .cache(networkCacheOptionsInfo: info)
    }
}
