//
//  String+MD5.swift
//  SYMoyaNetwork
//
//  Created by ShannonYang on 2021/8/24.
//  Copyright © 2021 Shannon Yang. All rights reserved.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

//MARK: - String
public extension String {
    func md5() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        let s = digestData.map { String(format: "%02hhx", $0) }.joined()
        return s
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



