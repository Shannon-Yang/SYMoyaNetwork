//
//  GitHubUserContent.swift
//  SYMoyaNetworkTests
//
//  Created by Shannon Yang on 2023/7/23.
//

import Foundation
import Moya
import SYMoyaNetwork

public enum GitHubUserContent {
    case downloadMoyaWebContent(String)
    case requestMoyaWebContent(String)
}

extension GitHubUserContent: TargetType {
    public var baseURL: URL { URL(string: "https://raw.githubusercontent.com")! }
    public var path: String {
        switch self {
        case .downloadMoyaWebContent(let contentPath), .requestMoyaWebContent(let contentPath):
            return "/Moya/Moya/master/web/\(contentPath)"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .downloadMoyaWebContent, .requestMoyaWebContent:
            return .get
        }
    }
    public var parameters: [String: Any]? {
        switch self {
        case .downloadMoyaWebContent, .requestMoyaWebContent:
            return nil
        }
    }
    public var parameterEncoding: ParameterEncoding { URLEncoding.default }
    public var task: Task {
        switch self {
        case .downloadMoyaWebContent:
            return .downloadDestination(defaultDownloadDestination)
        case .requestMoyaWebContent:
            return .requestPlain
        }
    }
    public var sampleData: Data {
        switch self {
        case .downloadMoyaWebContent, .requestMoyaWebContent:
            return Data(count: 4000)
        }
    }

    public var headers: [String: String]? { nil }
}
