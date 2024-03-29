//
//  URL+SYMoya.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/20.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import Foundation
import Moya

// MARK: - URL

extension URL {
    /// Initialize URL from Moya's `TargetType`.
    public init<T: SYTargetType>(target: T) {
        // When a TargetType's path is empty, URL.appendingPathComponent may introduce trailing /, which may not be wanted in some cases
        // See: https://github.com/Moya/Moya/pull/1053
        // And: https://github.com/Moya/Moya/issues/1049
        let targetPath = target.path
        if target.useCDN {
            if let cdnURL = target.cdnURL {
                if targetPath.isEmpty {
                    self = cdnURL
                } else {
                    self = cdnURL.appendingPathComponent(targetPath)
                }
            } else {
                if targetPath.isEmpty {
                    self = target.baseURL
                } else {
                    self = target.baseURL.appendingPathComponent(targetPath)
                }
            }
        } else {
            if targetPath.isEmpty {
                self = target.baseURL
            } else {
                self = target.baseURL.appendingPathComponent(targetPath)
            }
        }
    }
}
