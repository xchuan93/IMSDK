//
//  IMKXNSData+ZMSCrypto.h
//  payLoadProject
//
//  Created by Apple on 2018/7/4.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ZMSCrypto)
+ (NSData *)randomEncryptionKey;
+ (NSData *)secureRandomDataOfLength:(NSUInteger)length;
-(NSString *)base64String;
@end
