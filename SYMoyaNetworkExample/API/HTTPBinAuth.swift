//
//  HTTPBinAuth.swift
//  SYMoyaNetworkTests
//
//  Created by Shannon Yang on 2023/7/23.
//

import Foundation
import Moya
import SYMoyaNetwork

enum HTTPBinAuth: SYTargetType, AccessTokenAuthorizable {
    case basicAuth
    case bearer

    var baseURL: URL { URL(string: "http://httpbin.org")! }
    var path: String {
        switch self {
        case .basicAuth:
            return "/basic-auth/user/passwd"
        case .bearer:
            return "/bearer"
        }
    }

    var method: Moya.Method {
        switch self {
        case .basicAuth, .bearer:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .basicAuth,.bearer:
            return .requestPlain
        }
    }

    var sampleData: Data {
        switch self {
        case .basicAuth:
            return "{\"authenticated\": true, \"user\": \"user\"}".data(using: String.Encoding.utf8)!
        case .bearer:
            return "{\"authenticated\": true, \"token\": \"4D4A9C7D-F6E7-4FD7-BDBD-03880550A80D\"}".data(using: String.Encoding.utf8)!
        }
    }

    var headers: [String: String]? {
        switch self {
        case .basicAuth:
            return nil
        case .bearer:
            let bearer = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6Ikpva"
            return ["Authorization": bearer]
        }
    }

    var validationType: ValidationType {
        return .none
    }

    var authorizationType: AuthorizationType? {
        switch self {
        case .bearer:
            return  .bearer
        default:
            return nil
        }
    }
}
