//
//  HTTPBinImages.swift
//  SYMoyaNetworkExample
//
//  Created by Shannon Yang on 2023/11/13.
//  Copyright © 2023 Shannon Yang. All rights reserved.
// 

import Foundation
import Moya
import SYMoyaNetwork

enum HTTPBinImages: SYTargetType {
    case png
    
    var baseURL: URL {
        URL(string: "http://httpbin.org")!
    }
    
    var path: String {
        switch self {
        case .png:
            return "/image/png"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .png:
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
