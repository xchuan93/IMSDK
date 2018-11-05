//
//  IMKXNSData+ZMSCrypto.m
//  payLoadProject
//
//  Created by Apple on 2018/7/4.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXNSData+ZMSCrypto.h"
static NSInteger AESSize =32;
@implementation NSData (ZMSCrypto)
+ (NSData *)randomEncryptionKey {
    return [NSData secureRandomDataOfLength:AESSize];
}
+ (NSData *)secureRandomDataOfLength:(NSUInteger)length
{
    NSMutableData *randomData = [NSMutableData dataWithLength:length];
  __unused  int success = SecRandomCopyBytes(kSecRandomDefault, length, randomData.mutableBytes);
    return randomData;
}
-(NSString *)base64String{
   return  [self base64EncodedStringWithOptions:0];
}

@end
