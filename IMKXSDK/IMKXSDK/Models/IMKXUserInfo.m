//
//  IMKXUserInfo.m
//  IMSDKProject
//
//  Created by Apple on 2018/6/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXUserInfo.h"
#import "IMKXAFNetTool.h"
#import "IMKXUserInterFace.h"
#import "IMKXConstObject.h"
#import "IMKXSocketRocketUtility.h"
#import <AFNetworking/AFNetworking.h>
#define KTokenExpireDate 14*60  //token 每次请求时间
@interface IMKXUserInfo()
@property (nonatomic,assign)NSInteger timeCount;
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation IMKXUserInfo

-(void)setAccess_token:(NSString *)access_token{
    _access_token=access_token;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:KTokenExpireDate target:self selector:@selector(timeEvent:) userInfo:nil repeats:YES];
}

-(void)timeEvent:(NSTimer *)sender{
    [self.timer invalidate];
    self.timer=nil;
      //update token
    NSString *updateTokenUrl=KUpdateTokenUrl;
    [[IMKXAFNetTool shared] post:updateTokenUrl parameters:@{} httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        if (responseObj) {
            NSLog(@"token 更新成功=======");
            [IMKXConstObject shared].constToken=[responseObj objectForKey:@"access_token"];
            [IMKXConstObject shared].userInfo.access_token= [responseObj objectForKey:@"access_token"];
            [IMKXConstObject shared].userInfo.token_type= [responseObj objectForKey:@"token_type"];
            [IMKXConstObject shared].userInfo.userId= [responseObj objectForKey:@"user"];
            
            
            NSString *token=[IMKXConstObject shared].constToken;
            if (!token||token==nil) {
                return;
            }
 
        }
    } failure:^(NSString *error) {
        NSLog(@"token 更新失败========");
    }];
}


@end
