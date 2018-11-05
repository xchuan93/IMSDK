//
//  IMKXFriendListManage.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXBaseObject.h"

@interface IMKXFriendListManage : IMKXBaseObject
+(instancetype)defaultManage;   //获取单例对象
/**
 获取所有好友列表
 @param success  成功回调
 @param fail     失败回调
 */
-(void)getFriendListEventComplete:(void(^)(NSArray *responseObj))success fail:(void(^)(id error))fail;
/**
 搜索好友
 @param searchText 搜索的好友名称
 @param success    成功回调
 @param fail       失败回调
 */
-(void)searchFriendListEventByText:(NSString *)searchText complete:(void(^)(NSArray *responseObj))success fail:(void(^)(id error))fail;

/**
 获取所有群成员
 @param groupId  群ID
 @param success  成功回调
 @param fail     失败回调
 */
-(void)selectGroupMemberByGroupId:(NSString *)groupId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 添加群成员
 @param groupId  群ID
 @param memberList 要添加的成员ID数组
 @param success  成功回调
 @param fail     失败回调
 */
-(void)addGroupMemberByGroupId:(NSString *)groupId addMemberList:(NSArray *)memberList complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

/**
 删除群成员
 @param groupId  群ID
 @param memberId 要删除的群成员
 @param success  成功回调
 @param fail     失败回调
 */
-(void)deleteGroupMemberByGroupId:(NSString *)groupId deleteMember:(NSString *)memberId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;

@end
