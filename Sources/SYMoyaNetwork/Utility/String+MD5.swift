//
//  String+MD5.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/24.
//  Copyright © 2023 Shannon Yang. All rights reserved.
//

import CryptoKit
import Foundation

// MARK: - String

extension String {
    public func md5() -> String {
        let digest = Insecure.MD5.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    public var ext: String? {
        var ext = ""
        if let index = lastIndex(of: ".") {
            let extRange = self.index(index, offsetBy: 1)..<endIndex
            ext = String(self[extRange])
        }
        guard let firstSeg = ext.split(separator: "@").first else {
            return nil
        }
        return !firstSeg.isEmpty ? String(firstSeg) : nil
    }
}
