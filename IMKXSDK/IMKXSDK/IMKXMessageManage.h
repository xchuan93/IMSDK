//
//  IMKXMessageManage.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXBaseObject.h"
typedef NS_ENUM(NSUInteger, EmojiType) {
    emjTraval= 0,
    emjPeople,
    emjSymbols,
    emjFood,
    emjFlags,
    emjObjects,
    emjActivities,
    emjNature
};
@interface IMKXMessageManage : IMKXBaseObject
+(instancetype)defaultManage;   //获取单例对象
/**
  通过类型获取表情
 @param emjType  表情类型
 @param success  成功回调
 */
-(void)getEmjPicByType:(EmojiType)emjType complete:(void(^)(NSArray * emjArr))success;
/**
  发送消息功能
 @param cnvId    会话ID
 @param recId    接受者ID
 @param content  发送内容
 @param success  成功回调
 @param fail     失败回调
 */
-(void)sendMsgByCnvId:(NSString *)cnvId  receiveId:(NSString *)recId msgContet:(id)content complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 发送群消息功能
 @param groupId  GroupID
 @param content  发送内容
 @param success  成功回调
 @param fail     失败回调
 */
-(void)sendGroupMsgByGroupId:(NSString *)groupId msgContet:(id)content complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
  获取离线消息
 @param success  成功回调
 @param fail     失败回调
 */
-(void)getOffLineMessageComplete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;


/**
 获取推送消息
 @param notiId   推送通知ID
 @param success  成功回调
 @param fail     失败回调
 */
-(void)getPushMsgByNotificationId:(NSString *)notiId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 发送文件
 @param fileData 文件流
 @param cnvId    会话ID
 @param recId     接收ID
 @param success  成功回调
 @param fail     失败回调
 */

-(void)sendFile:(NSData *)fileData cnvId:(NSString *)cnvId  receiveId:(NSString *)recId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

@end
