//
//  String+MD5.swift
//  SYMoyaNetwork
//
//  Created by Shannon Yang on 2021/8/24.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import CryptoKit

//MARK: - String
public extension String {
    func md5() -> String {
        let digest = Insecure.MD5.hash(data: Data(self.utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    var ext: String? {
        var ext = ""
        if let index  = self.lastIndex(of: ".") {
            let extRange = self.index(index, offsetBy: 1)..<self.endIndex
            ext = String(self[extRange])
        }
        guard let firstSeg = ext.split(separator: "@").first else {
            return nil
        }
        return firstSeg.count > 0 ? String(firstSeg) : nil
    }
}



