//
//  IMKXUserManage.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMKXBaseObject.h"



 //socketDelegate
@protocol SocketConnectionDelegate <NSObject>
-(void)SocketConnectionOpen;
-(void)SocketConnectionClose;
-(void)SocketDidReceiveMessage:(id)message;
@end
@interface IMKXUserManage : IMKXBaseObject 
@property (nonatomic,weak) id<SocketConnectionDelegate> delegate;
+(instancetype)defaultManage;   //获取单例

/**
  初始化
   @param email      用户邮箱
   @param password   用户密码
   @param appKey     用户APPKey
   @param bundleId   工程ID
   @param pushToken  deviceToken
   @param success    成功回调
   @param fail       失败回调
 */
-(void)initWithEmail:(NSString *)email password:(NSString *)password appkey:(NSString *)appKey bunldId:(NSString *)bundleId token:(NSString *)pushToken complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 通过ID获取用户信息
 @param userId     用户ID
 @param success    成功回调
 @param fail       失败回调
 */
-(void)getUserInfoById:(NSString *)userId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;


/**
 登出
 @param success    成功回调
 @param fail       失败回调
 */
-(void)loginOutEventComplete:(void(^)(void))success fail:(void(^)(id error))fail;


//推送内容
-(void)locationPushByContent:(NSString *)pushContent;

@end
