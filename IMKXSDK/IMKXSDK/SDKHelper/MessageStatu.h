//
//  MessageStatu.h
//  IMKXSDK
//
//  Created by Apple on 2018/8/29.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageStatu : NSObject

+ (MessageStatu *)sharedOneTimeClass;

- (BOOL)messageStatu;

- (void)setMessagestatu:(BOOL)statu;

@end
