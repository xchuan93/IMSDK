//
//  IMKXUserInterFace.h
//  IMSDKProject
//
//  Created by Apple on 2018/6/21.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KBaseUrl @"https://web3.imkexin.com/"
//#define KBaseUrl @"https://web3.chatbox.tech/"
#define KgetUrl(linkUrl)  [KBaseUrl stringByAppendingString:linkUrl];
#define KLogin  KgetUrl(@"login/sdk?persist=true")   //登录
#define KClient KgetUrl(@"")
#define KGetConnList  KgetUrl(@"connections")   //获取联系列表ID 
#define KGetFriendList  KgetUrl(@"connections")   //获取联系列表
#define KSearchUser  KgetUrl(@"search/contacts")   //搜索用户
#define KInvitaUrl KgetUrl(@"connections")  //邀请好友
#define KUpdateTokenUrl KgetUrl(@"access") //更新token
#define KLoginOutUrl  [KBaseUrl stringByAppendingString:(@"access/logout")]  //登出

#define KSocketUrl [KBaseUrl stringByAppendingString:(@"await?access_token=")]

//register Clients
#define KGetPreKeysUrl [KBaseUrl stringByAppendingString:@"/users/prekeys"]

#define KRigisterClientsUrl [KBaseUrl stringByAppendingString:@"clients"]

#define KGetUserClient(user)  [KBaseUrl stringByAppendingString:@"user/%@/clients",#user] //获取用户Client





//创建会话
#define KCreateCnvUrl [KBaseUrl stringByAppendingString:@"conversations"]
#define KGetAllCnvUrl [KBaseUrl stringByAppendingString:@"conversations"]
//group
#define KCreateGroup  KgetUrl(@"conversations")

#define KGroupMenber  KgetUrl(@"conversations?ids=")
#define KAddMember KgetUrl(@"conversations/")

#define KUploadAssetUrl  [KBaseUrl stringByAppendingString:@"assets/v3/"]
//push
#define KRegisterPushTokenUrl [KBaseUrl stringByAppendingString:@"push/tokens"]
#define KFetchLastNotiUrl [KBaseUrl stringByAppendingString:@"notifications/last"]
#define KFetchNotiUrl [KBaseUrl stringByAppendingString:@"notifications"] //获取离线消息

//group //put 修改群名称
#define KUpdateGroupName [KBaseUrl stringByAppendingString:@"conversations/"]


@interface IMKXUserInterFace : NSObject


@end
