//
//  IMKXConstObject.h
//  SecretSDKProject
//
//  Created by Apple on 2018/6/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SDKPrefixHeader.pch"
#import "IMKXUserInfo.h"
#import "IMKXClientDeviceModel.h"
#import "IMKXLoginInfo.h"
@interface IMKXConstObject : NSObject
+(IMKXConstObject *)shared;

-(void)uploadAsset:(NSData *)fileData;
//+ (NSString *)descriptionWithLocale:(id)locale;
@property (nonatomic,strong)NSString *constToken;
@property (nonatomic,strong)NSString *constCookie;
@property (nonatomic,strong)NSMutableArray< IMKXClientDeviceModel *> *clientDeviceArr;
@property (nonatomic,strong)NSString *socketUrl;
@property (nonatomic,strong)IMKXUserInfo * userInfo;
@property (nonatomic,strong)NSString *sendId;   //当前clientID
@property (nonatomic,strong)NSArray * registerClientArr; //保存已经存在的client

@property (nonatomic,strong)IMKXLoginInfo *loginInfo;

@property (nonatomic,strong)NSString *constSince;

@property (nonatomic,strong)NSString *nextSince;

@end




