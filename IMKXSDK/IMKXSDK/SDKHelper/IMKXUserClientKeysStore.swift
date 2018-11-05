//
//  IMKXUserClientKeysStore.swift
//  payLoadProject
//
//  Created by Apple on 2018/7/3.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit
import WireSystem
import WireCryptobox
import WireUtilities

 public class IMKXUserClientKeysStore: NSObject {
    public static var encryptionSessions : EncryptionSessionsDirectory? = nil
    public static var encryptionContext:EncryptionContext? = nil
    public static let MaxPreKeyID : UInt16 = UInt16.max-1
    public static var count : Int = 0
    fileprivate static var pendingSessionsCache : [EncryptionSessionIdentifier : EncryptionSessionsDirectory] = [:]
    
    public class var sharedInstance: IMKXUserClientKeysStore {
        struct Static {
            static let instance = IMKXUserClientKeysStore()
        }
        return Static.instance
    }
    
    public class func setUp(){
        if (encryptionContext == nil) {
//            let randomkey
//                = UserDefaults.standard.string(forKey: "randomkey")
            var path = NSHomeDirectory()
            path = path + "/Documents/otr/"
            if (FileManager.default.fileExists(atPath: path)) {
                encryptionContext =  EncryptionContext(path: URL.init(string: path)!);
            }
        }
    }
    
    public static func setupContext(in directory: URL) -> EncryptionContext? {
        
        FileManager.default.createAndProtectDirectory(at: directory)
        return EncryptionContext(path: directory)
    }
    
    public func generateMoreKeys(_ count:UInt16 = 1 ,start: UInt16 = 0)  -> NSMutableArray
    {
        let resultArr = NSMutableArray.init()
//        let randomkey
//            = UserDefaults.standard.string(forKey: "randomkey")
        var path = NSHomeDirectory()
        path = path + "/Documents/otr/"
        if (!FileManager.default.fileExists(atPath: path)) {
            FileManager.default.createAndProtectDirectory(at: URL.init(fileURLWithPath: path))
        }
        IMKXUserClientKeysStore.encryptionContext =  EncryptionContext(path: URL.init(string: path)!);
        let aa :  [(id: UInt16, prekey: String)] = []
        if count>0 {
            var newPreKeys :  [(id: UInt16, prekey: String)] = []
            let range = preKeysRange(count, start: start)
            IMKXUserClientKeysStore.encryptionContext?.perform({(sessionsDirectory) in
                do {
                    IMKXUserClientKeysStore.encryptionSessions = sessionsDirectory
                    IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
                    newPreKeys = try sessionsDirectory.generatePrekeys(range)
                    if newPreKeys.count == 0 {
                    }
                }
                catch _ as NSError {
                }
            })
            
            for item in newPreKeys{
                let idKey  = String.init(item.id );
                let value = item.prekey;
                let tempDic  = ["id":idKey,"prekey":value] as [String : Any]
                resultArr.add(tempDic)
            }
            return resultArr ;
        }
        return aa as! NSMutableArray;
    }
    
    
    fileprivate func preKeysRange(_ count: UInt16, start: UInt16) -> CountableRange<UInt16> {
        if start >= IMKXUserClientKeysStore.MaxPreKeyID-count {
            return CountableRange(0..<count)
        }
        return CountableRange(start..<(start + count))
    }
    
    open func lastPreKey() -> [String:Any] {
        var error: NSError?
        var internalLastPreKey:String? = nil
        var path = NSHomeDirectory()
        path = path + "/Documents/otr/"
        if (!FileManager.default.fileExists(atPath: path)) {
            FileManager.default.createAndProtectDirectory(at: URL.init(fileURLWithPath: path))
        }
        
        if internalLastPreKey == nil {
            IMKXUserClientKeysStore.encryptionContext?.perform({ [weak self] (sessionsDirectory) in
                guard self != nil  else { return }
                do {
                    IMKXUserClientKeysStore.encryptionSessions = sessionsDirectory
                    IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
                    internalLastPreKey = try sessionsDirectory.generateLastPrekey()
                } catch let anError as NSError {
                    error = anError
                }
            })
        }
        if error != nil {
            
        }
        let lastPreKeyPayLoadData : [String :Any] = ["key" : internalLastPreKey!,"id":NSNumber(value: CBOX_LAST_PREKEY_ID)]
        return lastPreKeyPayLoadData
    }
    
    
    public class func decrypt(identifier:String,prekeyMessage:Data) ->Data{
        
        IMKXUserClientKeysStore.encryptionSessions = pendingSessionsCache[EncryptionSessionIdentifier(rawValue: identifier)]
        if (IMKXUserClientKeysStore.encryptionSessions == nil) {
            
            do{
                IMKXUserClientKeysStore.encryptionSessions = EncryptionSessionsDirectory(generatingContext: IMKXUserClientKeysStore.encryptionContext!)
                IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
                let decoded = try IMKXUserClientKeysStore.encryptionSessions?.createClientSessionAndReturnPlaintext(for: EncryptionSessionIdentifier(rawValue: identifier), prekeyMessage: prekeyMessage)
                IMKXUserClientKeysStore.count = 2
//                pendingSessionsCache[EncryptionSessionIdentifier(rawValue: identifier)] = IMKXUserClientKeysStore.encryptionSessions
                return decoded!
            }catch {
                print("66")
            }
            return Data()
            
        }else{
            IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
            
            do{
                let decoded = try IMKXUserClientKeysStore.encryptionSessions?.decrypt(prekeyMessage, from: EncryptionSessionIdentifier(rawValue: identifier))
                return decoded!
            }catch {
                print(error)
            }
            
            return Data()
        }
    }
    
    class public func establishEncryptSession(plainText:Data,prekey:String,identifier:String) ->String {
        
        IMKXUserClientKeysStore.encryptionSessions = pendingSessionsCache[EncryptionSessionIdentifier(rawValue: identifier)]
        if IMKXUserClientKeysStore.encryptionSessions == nil {
            do{
                IMKXUserClientKeysStore.encryptionSessions = EncryptionSessionsDirectory(generatingContext: IMKXUserClientKeysStore.encryptionContext!)
                IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
                establishClientEncryptSession(prekey: prekey, identifier: identifier)
                let prekeyMessage = try IMKXUserClientKeysStore.encryptionSessions?.encrypt(plainText, for: EncryptionSessionIdentifier(rawValue: identifier))
                pendingSessionsCache[EncryptionSessionIdentifier(rawValue: identifier)] = IMKXUserClientKeysStore.encryptionSessions
                return prekeyMessage!.base64EncodedString(options: [])
            }catch{
                print("66")
            }
        }
        do{
            IMKXUserClientKeysStore.encryptionSessions = EncryptionSessionsDirectory(generatingContext: IMKXUserClientKeysStore.encryptionContext!)
            IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
            let prekeyMessage = try IMKXUserClientKeysStore.encryptionSessions?.encrypt(plainText, for: EncryptionSessionIdentifier(rawValue: identifier))
            return prekeyMessage!.base64EncodedString(options: [])
        }catch{
            print("66")
        }
        return ""
    }
    
    static func establishClientEncryptSession(prekey:String,identifier:String) {
        
        IMKXUserClientKeysStore.encryptionSessions = EncryptionSessionsDirectory(generatingContext: IMKXUserClientKeysStore.encryptionContext!)
        IMKXUserClientKeysStore.encryptionSessions?.debug_disableContextValidityCheck = true
        try! IMKXUserClientKeysStore.encryptionSessions?.createClientSession(EncryptionSessionIdentifier(rawValue: identifier), base64PreKeyString: prekey)
        
    }
    
}
 
