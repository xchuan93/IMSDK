//
//  MessageStatu.m
//  IMKXSDK
//
//  Created by Apple on 2018/8/29.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "MessageStatu.h"

@interface MessageStatu()

@property (nonatomic,assign) BOOL statu;

@end

@implementation MessageStatu

static MessageStatu *__messageClass;

+ (MessageStatu *)sharedOneTimeClass{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __messageClass = [[MessageStatu alloc]init];
        __messageClass.statu = NO;
        
    });
    
    return __messageClass;
}

- (BOOL)messageStatu{
    return __messageClass.statu;
}
- (void)setMessagestatu:(BOOL)statu{
    __messageClass.statu = statu;
}

@end
