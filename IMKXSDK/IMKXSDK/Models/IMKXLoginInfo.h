//
//  IMKXLoginInfo.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMKXLoginInfo : NSObject
@property (nonatomic,strong)NSString *email;
@property (nonatomic,strong)NSString *password;
@property (nonatomic,strong)NSString *appKey;
@property (nonatomic,strong)NSString *bundleid;
@end
