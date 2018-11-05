//
//  IMKXConversationManage.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXConversationManage.h"
#import "AFNRequest/IMKXAFNetTool.h"
#import "IMKXUserInterFace.h"
#import <AFNetworking/AFNetworking.h>
#import "IMKXToolHelper.h"
#import "IMKXAFNetTool.h"
#define KUserName @"handleName"
@interface IMKXConversationManage()
@property (nonatomic,strong)NSMutableString *idSet;
@property (nonatomic,strong)NSMutableArray *sentArr;  //发送好友邀请ID
@property (nonatomic,strong)NSMutableArray *pendArr;//等待状态ID

@property (nonatomic,strong)NSMutableArray *sentResponse;  //发送好友邀请
@property (nonatomic,strong)NSMutableArray *pendResponse;//等待状态


@property (nonatomic,strong)NSMutableString *cnvIdSet;

@property (nonatomic,strong)NSMutableArray *friendList;

@property (nonatomic,strong)NSMutableArray *cnvResultArr;
@end

@implementation IMKXConversationManage

-(NSMutableArray *)cnvResultArr{
    if (!_cnvResultArr) {
        _cnvResultArr=[[NSMutableArray alloc] init];
    }
    return _cnvResultArr;
}

-(NSMutableArray *)friendList{
    if (!_friendList) {
        _friendList=[[NSMutableArray alloc] init];
    }
    return _friendList;
}

-(NSMutableString *)idSet{
    if (!_idSet) {
        _idSet=[[NSMutableString alloc] init];
    }
    return _idSet;
}

-(NSMutableString *)cnvIdSet{
    if (!_cnvIdSet) {
        _cnvIdSet=[[NSMutableString alloc] init];
    }
    return _cnvIdSet;
}


-(NSMutableArray *)sentResponse{
    if (!_sentResponse) {
        _sentResponse=[[NSMutableArray alloc] init];
    }
    return  _sentResponse;
}

-(NSMutableArray *)pendResponse{
    if (!_pendResponse) {
        _pendResponse=[[NSMutableArray alloc] init];
    }
    return  _pendResponse;
}


-(NSMutableArray *)sentArr{
    if (!_sentArr) {
        _sentArr=[[NSMutableArray alloc] init];
    }
    return  _sentArr;
}

-(NSMutableArray *)pendArr{
    if (!_pendArr) {
        _pendArr=[[NSMutableArray alloc] init];
    }
    return  _pendArr;
}


+(instancetype) defaultManage{
    static IMKXConversationManage * manager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =[[IMKXConversationManage alloc] init];
    });
    return manager;
}

-(void)getAllConversationEventComplete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
 
    NSString *getallConvRul= @"https://web3.imkexin.com/conversations/sdk";
    
    [[IMKXAFNetTool shared] post:getallConvRul parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}


-(void)dealConversationInfoBy:(id)respone complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    LRWeakSelf(self);
      NSString *urlStr = KGetConnList;
    [[IMKXAFNetTool shared] post:urlStr parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
          [weakself.cnvResultArr removeAllObjects];
        
        NSArray *connArr=[responseObj objectForKey:@"connections"];
        if (!([connArr count]>0)) {
            success(@[]);
            return ;
        }
        
        for (NSInteger i=0; i<connArr.count; i++) {
            NSDictionary *item=[connArr objectAtIndex:i];
         __unused   NSString *status=[item objectForKey:@"status"];
            NSString *to=[[item objectForKey:@"to"] stringByAppendingString:@","];
            //
            [weakself.cnvIdSet  appendString:to];
        }
            
            //通过ID 获取好友
            //获取好友列表
              id cnvResponse=respone;
            if (!(weakself.cnvIdSet.length>0)) {
                [weakself returnAllConversationList:respone complete:success];
                return ;
            }
            NSRange deleteRange = { [self.cnvIdSet length] - 1, 1 };
            [self.cnvIdSet deleteCharactersInRange:deleteRange]; // 获取所有好友ID
            NSLog(@"self.cnvIdSet=======%@",self.cnvIdSet);
            NSString *  getFriendUrl =[@"https://web3.imkexin.com/users?ids=" stringByAppendingString:self.cnvIdSet];
            [[IMKXAFNetTool shared] post:getFriendUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
            } success:^(id responseObj) {
                //循环遍历
                NSArray *resultArr=responseObj;
                [weakself.friendList removeAllObjects];
                if (resultArr.count>0) {
                    for (NSDictionary *item in resultArr) {
                        [weakself.friendList addObject:item];
                    }
                }
                NSArray *cnvList=[cnvResponse objectForKey:@"conversations"];
                for (NSDictionary *cnvItem in cnvList) {
                    if (![[cnvItem allKeys] containsObject:@"members"]) {
//                        [weakself returnAllConversationList:respone complete:success];
                        [weakself.cnvResultArr addObject:cnvItem];
                          continue ;
                    }
                    NSDictionary *tempCnvItem=[cnvItem objectForKey:@"members"];
                    if (![[tempCnvItem allKeys] containsObject:@"others"]) {
                          [weakself.cnvResultArr addObject:cnvItem];
                        continue;
                    }
                    NSArray *membersList =[[cnvItem objectForKey:@"members"] objectForKey:@"others"];
                    for (NSDictionary *memberItem in membersList) {
                         NSString *memberId=[memberItem objectForKey:@"id"];  //memID
                        for (NSInteger i=0; i<weakself.friendList.count; i++) {
                           
                            NSString *friendId=[[weakself.friendList objectAtIndex:i] objectForKey:@"id"]; //FriendId
                            if ([memberId isEqualToString:friendId]) {
                                NSDictionary *memeberDic=[cnvItem objectForKey:@"members"];
                                NSMutableDictionary *enableMemberDic=[NSMutableDictionary dictionaryWithDictionary:memeberDic]; //Mem Dic
                                NSMutableArray *enableArr=[NSMutableArray arrayWithArray:membersList]; //memList
                                NSString *userName=[[weakself.friendList objectAtIndex:i] objectForKey:@"handle"];
                                [enableMemberDic setObject:userName forKey:KUserName];
                                [enableArr addObject:enableMemberDic];
                                [enableMemberDic setObject:enableArr forKey:@"others"];
                                
                                
//                                NSLog(@"enableMemberDic========%@",enableMemberDic);
                                
                                NSMutableDictionary *enableCnvDic=[NSMutableDictionary dictionaryWithDictionary:cnvItem];
                                [enableCnvDic setObject:enableMemberDic
                                                 forKey:@"members"];
                                [weakself.cnvResultArr addObject:enableCnvDic];
                            }
                            else {
                                [weakself.cnvResultArr addObject:cnvItem];
                            }
                        }
                      
                }
 
                    success(weakself.cnvResultArr);
                }
  
            } failure:^(id error) {
        
                fail(error);
            }];
            
        
    } failure:^(id error) {
 
            fail(error);
    }];
}


-(void)returnAllConversationList:(id) response complete:(void(^)(id responseObj))success{
    NSArray *cnvList =[response objectForKey:@"conversations"];
    [self.cnvResultArr removeAllObjects];
    if ([cnvList count]>0) {
        for (NSDictionary *item in cnvList) {
            [self.cnvResultArr addObject:item];
        }
 
        success(self.cnvResultArr);
        
    }
    else {
        success(@[]);
    }
}


-(void)getCnverstInfoByCnv:(NSString *)cnvId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *url=[@"https://web3.imkexin.com/conversations/" stringByAppendingString:cnvId];
    [[IMKXAFNetTool shared] post:url parameters:@{} httpMethod:@"get" progress:^(NSProgress *uploadProgress) {
        
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(fail);
    }];
}
-(void)getAllFriendQuestEventComplete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    //获取所有 好友ID
    __weak IMKXConversationManage *weakSelf =self;
    [weakSelf.idSet setString:@""];
    [weakSelf.sentArr removeAllObjects];
    [weakSelf.pendArr removeAllObjects];
    
    [weakSelf.sentResponse removeAllObjects];
    [weakSelf.pendResponse removeAllObjects];
    NSString *urlStr = KGetConnList;
    [[IMKXAFNetTool shared] post:urlStr parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
 
        NSArray *connArr=[responseObj objectForKey:@"connections"];
        for (NSInteger i=0; i<connArr.count; i++) {
            NSDictionary *item=[connArr objectAtIndex:i];
            NSString *status=[item objectForKey:@"status"];
            NSString *to=[[item objectForKey:@"to"] stringByAppendingString:@","];
            //
            if (![status containsString:@"accepted"]&&![status containsString:@"cancelled"]&&![status containsString:@"ignored"] ) {
                [weakSelf.idSet appendString:to];
                
                if ([status containsString:@"sent"]) {
                    [weakSelf.sentArr addObject:[item objectForKey:@"to"]];
                }
                else if([status containsString:@"pend"]){
                    [weakSelf.pendArr addObject:[item objectForKey:@"to"]];
                }
                
            }
        }
        
        if (!(weakSelf.idSet.length>0)) {
            success(@{@"sent":@[],@"pend":@[]});
            return ;
        }
        //获取好友列表
        NSRange deleteRange = { [self.idSet length] - 1, 1 };
        [self.idSet deleteCharactersInRange:deleteRange]; // 获取所有好友ID
        NSString *  getFriendUrl =[@"https://web3.imkexin.com/users?ids=" stringByAppendingString:self.idSet];
        [[IMKXAFNetTool shared] post:getFriendUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
        } success:^(id responseObj) {
             NSArray *resultArr=responseObj;
            if (resultArr.count>0) {
                for (NSDictionary *item in resultArr) {
                    NSString *itemId= [item objectForKey:@"id"];
                    if ([weakSelf.sentArr containsObject:itemId]) {
                        [weakSelf.sentResponse addObject:item];
                    }
                    else if([weakSelf.pendArr containsObject:itemId]){
                           [weakSelf.pendResponse addObject:item];
                    }
  
                }
            }
            success(@{@"sent":weakSelf.sentResponse,@"pend":weakSelf.pendResponse});
        } failure:^(id error) {
            fail(error);
        }];
    } failure:^(id error) {
        fail(error);
    }];
}
//添加好友请求
-(void)sendAddFriendRequestById:(NSString *)friendId friendName:(NSString *)friendName message:(NSString *)requestMessage complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *invitaUrl=KInvitaUrl;
    NSDictionary *param=@{@"user":friendId,@"name":friendName,@"message":requestMessage};
    [[IMKXAFNetTool shared] post:invitaUrl parameters:param httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}
//创建群聊
-(void)createGroupEventByGroupName:(NSString *)groupName selectFriendList:(NSArray *)friendList complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *urlStr = KCreateGroup;
    [[IMKXAFNetTool shared] post:urlStr parameters:@{@"users":friendList,@"name":groupName} httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
    
}
//更新群名称
-(void)updateGroupName:(NSString *)groupName ByCnvId:(NSString *)cnvId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *updateUrl =[KUpdateGroupName stringByAppendingString:cnvId];
    [[IMKXAFNetTool shared] post:updateUrl parameters:@{@"name":groupName} httpMethod:@"PUT" progress:^(NSProgress *uploadProgress) {
        
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
    
    
}

//处理好友请求
-(void)dealRequestById:(NSString *)Id  isAccept:(RequestState) acceptEnable complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
   NSString *acceptFlag=@"ignored";
    if (acceptEnable==accepted) {
        acceptFlag =@"accepted";
    }
    else if(acceptEnable==cancelled){
        acceptFlag =@"cancelled";
    }

    NSString *dealConn=[@"https://web3.imkexin.com/connections/" stringByAppendingString:Id];
    NSDictionary *param=@{@"status":acceptFlag};
    [[IMKXAFNetTool shared] post:dealConn parameters:param httpMethod:@"PUT" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}
@end
