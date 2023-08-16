//
//  HttpBin.swift
//  SYMoyaNetworkTests
//
//  Created by Shannon Yang on 2023/7/23.
//

import Foundation
import Moya
import SYMoyaNetwork

enum HTTPBin: SYTargetType, AccessTokenAuthorizable {
    case basicAuth
    case bearer
    case post
    case upload(file: URL)
    case uploadMultipartFormData(MultipartFormData, [String: Any]?)
    case uploadMultipartBodyParts([MultipartFormBodyPart], [String: Any]?)
    case validatedUploadMultipartFormData(MultipartFormData, [String: Any]?, [Int])
    case validatedUploadMultipartBodyParts([MultipartFormBodyPart], [String: Any]?, [Int])

    var baseURL: URL { URL(string: "http://httpbin.org")! }
    var path: String {
        switch self {
        case .basicAuth:
            return "/basic-auth/user/passwd"
        case .bearer:
            return "/bearer"
            case .post, .upload, .uploadMultipartBodyParts, .uploadMultipartFormData, .validatedUploadMultipartBodyParts, .validatedUploadMultipartFormData:
            return "/post"
        }
    }

    var method: Moya.Method {
        switch self {
        case .basicAuth, .bearer:
            return .get
        case .post, .upload, .uploadMultipartBodyParts, .uploadMultipartFormData, .validatedUploadMultipartBodyParts, .validatedUploadMultipartFormData:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .basicAuth, .post, .bearer:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case .upload(let fileURL):
            return .uploadFile(fileURL)
        case .uploadMultipartFormData(let data, let urlParameters), .validatedUploadMultipartFormData(let data, let urlParameters, _):
            if let urlParameters = urlParameters {
                return .uploadCompositeMultipartFormData(data, urlParameters: urlParameters)
            } else {
                return .uploadMultipartFormData(data)
            }
        case .uploadMultipartBodyParts(let bodyParts, let urlParameters), .validatedUploadMultipartBodyParts(let bodyParts, let urlParameters, _):
            if let urlParameters = urlParameters {
                return .uploadCompositeMultipart(bodyParts, urlParameters: urlParameters)
            } else {
                return .uploadMultipart(bodyParts)
            }
        }
    }

    var sampleData: Data {
        switch self {
        case .basicAuth:
            return "{\"authenticated\": true, \"user\": \"user\"}".data(using: String.Encoding.utf8)!
        case .bearer:
            return "{\"authenticated\": true, \"token\": \"4D4A9C7D-F6E7-4FD7-BDBD-03880550A80D\"}".data(using: String.Encoding.utf8)!
        case .post, .upload, .uploadMultipartBodyParts, .uploadMultipartFormData, .validatedUploadMultipartBodyParts, .validatedUploadMultipartFormData:
            return "{\"args\": {}, \"data\": \"\", \"files\": {}, \"form\": {}, \"headers\": { \"Connection\": \"close\", \"Content-Length\": \"0\", \"Host\": \"httpbin.org\" },  \"json\": null, \"origin\": \"198.168.1.1\", \"url\": \"https://httpbin.org/post\"}".data(using: String.Encoding.utf8)!
        }
    }

    var headers: [String: String]? { nil }

    var validationType: ValidationType {
        switch self {
        case .validatedUploadMultipartFormData(_, _, let codes), .validatedUploadMultipartBodyParts(_, _, let codes):
            return .customCodes(codes)
        default:
            return .none
        }
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

// MARK: - Upload Multipart Helpers

extension HTTPBin {
    static func createTestMultipartFormData() -> [MultipartFormBodyPart] {
        let url = testImageUrl
        let string = "some data"
        guard let data = string.data(using: .utf8) else {
            fatalError("Failed creating Data from String \(string)")
        }
        return [
            MultipartFormBodyPart(provider: .file(url), name: "file", fileName: "testImage"),
            MultipartFormBodyPart(provider: .data(data), name: "data")
        ]
    }
}
