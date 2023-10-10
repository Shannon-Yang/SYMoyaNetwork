// swiftlint:disable force_unwrapping

import Foundation
import Moya
import SYMoyaNetwork

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public struct GitHub2: SYTargetType {
    public var baseURL: URL { URL(string: "https://api.github.com")! }
    public var path: String {
        return "/zen"
    }
    public var method: Moya.Method { .get }
    
    public var networkCacheType: NetworkCacheType {
        var conf = DiskStorage.Config(name: "", sizeLimit: 0)
        conf.expiration = .seconds(100)
        let info = NetworkCacheType.NetworkCacheOptionsInfo.init(diskStorageConfig: conf)
        return .syMoyaNetworkCache(networkCacheOptionsInfo: info)
    }

    public var task: Task {
        return .requestPlain
    }
    public var validationType: ValidationType {
        return .successCodes
    }
    public var sampleData: Data {
        return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
    }
    public var headers: [String: String]? { nil }
}

public enum GitHub {
    case zen
    case userProfile(String)
    case userRepositories(String)
    case userDevkapilbansal
    case userDevkapilbansalFollowers
}

extension GitHub {
    public var baseURL: URL { URL(string: "https://api.github.com")! }
    public var path: String {
        switch self {
        case .zen:
            return "/zen"
        case .userProfile(let name):
            return "/users/\(name.urlEscaped)"
        case .userRepositories(let name):
            return "/users/\(name.urlEscaped)/repos"
        case .userDevkapilbansal:
            return "/users/devkapilbansal"
        case .userDevkapilbansalFollowers:
            return "/devkapilbansal/followers"
        }
    }
    public var method: Moya.Method { .get }
    
    public var networkCacheType: NetworkCacheType {
        var conf = DiskStorage.Config(name: "", sizeLimit: 0)
        conf.expiration = .seconds(100)
        let info = NetworkCacheType.NetworkCacheOptionsInfo.init(diskStorageConfig: conf)
        return .syMoyaNetworkCache(networkCacheOptionsInfo: info)
    }

    public var task: Task {
        switch self {
        case .userRepositories:
            return .requestParameters(parameters: ["sort": "pushed"], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .zen:
            return .successCodes
        default:
            return .none
        }
    }
    public var sampleData: Data {
        switch self {
        case .zen:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .userProfile(let name):
            return "{\"login\": \"\(name)\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .userRepositories(let name):
            return "[{\"name\": \"\(name)\"}]".data(using: String.Encoding.utf8)!
        case .userDevkapilbansal:
            return "test".data(using: .utf8)!
        case .userDevkapilbansalFollowers:
            return "test2".data(using: .utf8)!
        }
    }
    public var headers: [String: String]? { nil }
    
    public var dataResponseSerializer: some BatchDataResponseSerializerProtocol {
        return .string(atKeyPath: nil)
    }
}

public func url(_ route: TargetType) -> String {
    route.baseURL.appendingPathComponent(route.path).absoluteString
}
