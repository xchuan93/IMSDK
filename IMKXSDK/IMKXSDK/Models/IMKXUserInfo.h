//
//  IMKXUserInfo.h
//  IMSDKProject
//
//  Created by Apple on 2018/6/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMKXUserInfo : NSObject
@property (nonatomic,strong)NSString *access_token;
@property (nonatomic,strong)NSString *access_cookie;
@property (nonatomic,strong)NSString *token_type;
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *passWord;
@end
