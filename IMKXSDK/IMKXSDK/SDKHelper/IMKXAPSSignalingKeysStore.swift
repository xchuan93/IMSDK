//
//  IMKXAPSSignalingKeysStore.swift
//  payLoadProject
//
//  Created by Apple on 2018/7/3.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

public class SignalingKeys:NSObject {
      @objc public let verificationKey : Data
    @objc public let decryptionKey : Data
    
    init(verificationKey: Data? = nil, decryptionKey: Data? = nil) {
        
        self.verificationKey = verificationKey ??  NSData.secureRandomData(ofLength:IMKXAPSSignalingKeysStore.defaultKeyLengthBytes )
        self.decryptionKey = decryptionKey ?? NSData.secureRandomData(ofLength: IMKXAPSSignalingKeysStore.defaultKeyLengthBytes)
    }
}

public class IMKXAPSSignalingKeysStore: NSObject {
    internal var verificationKey : Data!
    internal var decryptionKey : Data!
    
    internal static let verificationKeyAccountName = "APSVerificationKey"
    internal static let decryptionKeyAccountName = "APSDecryptionKey"
    internal static let defaultKeyLengthBytes : UInt = 256 / 8

    public func createKeys() -> SignalingKeys {
        return SignalingKeys()
    }
 
    
}
