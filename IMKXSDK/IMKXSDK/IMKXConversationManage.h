//
//  IMKXConversationManage.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXBaseObject.h"
typedef NS_ENUM(NSUInteger, RequestState) {
    accepted = 0,
    ignored,
    cancelled
};
@interface IMKXConversationManage : IMKXBaseObject
+(instancetype)defaultManage;   //获取单例对象

/**
 获取好友管理请求(包括发送好友请求、接收对方好友请求)
 @param success        成功回调
 @param fail           失败回调
 */
-(void)getAllFriendQuestEventComplete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;
/**
 获取当前用户会话
 @param success        成功回调
 @param fail           失败回调
  */
-(void)getAllConversationEventComplete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 获取指定会话信息
@param cnvId      会话ID
 @param success   成功回调
 @param fail      失败回调
 */
-(void)getCnverstInfoByCnv:(NSString *)cnvId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 发送添加好友请求
 @param friendId       好友ID
 @param friendName     好友名称
 @param requestMessage 添加请求信息
 @param success        成功回调
 @param fail           失败回调
 */
-(void)sendAddFriendRequestById:(NSString *)friendId friendName:(NSString *)friendName message:(NSString *)requestMessage complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;




/**
 创建群聊
 @param groupName   群聊名称
 @param friendList  要加入群聊的ID数组
 @param success     成功回调
 @param fail        失败回调
 */
-(void)createGroupEventByGroupName:(NSString *)groupName selectFriendList:(NSArray *)friendList complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;


/**
 更新群聊名称
 @param groupName   群聊名称
 @param cnvId       会话ID
 @param success     成功回调
 @param fail        失败回调
 */
-(void)updateGroupName:(NSString *)groupName ByCnvId:(NSString *)cnvId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 处理好友请求/通过/忽略
 @param Id             好友ID
 @param acceptEnable   是否接受
 @param success        成功回调
 @param fail           失败回调
 */
-(void)dealRequestById:(NSString *)Id  isAccept:(RequestState) acceptEnable complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;
@end
