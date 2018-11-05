//
//  IMKXFriendListManage.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMKXFriendListManage.h"
#import "IMKXUserManage.h"
#import "IMKXUserInterFace.h"
#import "IMKXAFNetTool.h"
#import <AFNetworking/AFNetworking.h>
#import "IMKXConstObject.h"
#import "IMKXToolHelper.h"
@interface IMKXFriendListManage()
@property (nonatomic,strong)NSMutableString *idSet;
@property (nonatomic,strong) NSMutableArray *dataList;
@property (nonatomic,strong)NSMutableDictionary *conversationDic;
@property (nonatomic,strong) NSMutableArray *searchList;


@property (nonatomic,strong) NSMutableArray *friendStatusList;


@property (nonatomic,strong)NSMutableArray *statusFriendArr;
@property (nonatomic,strong)NSMutableArray *statusSendRequestArr;
@property (nonatomic,strong)NSMutableArray *statusPendRequestArr;

@property (nonatomic,strong)NSMutableArray *statusNormalAddFriendArr;

@end
@implementation IMKXFriendListManage
+(instancetype) defaultManage{
    static IMKXFriendListManage * manager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =[[IMKXFriendListManage alloc] init];
    });
    return manager;
}

-(NSMutableArray *)statusNormalAddFriendArr{
    if (!_statusNormalAddFriendArr) {
        _statusNormalAddFriendArr=[[NSMutableArray alloc] init];
    }
    return _statusNormalAddFriendArr;
}

-(NSMutableArray *)statusFriendArr{
    if (!_statusFriendArr) {
        _statusFriendArr=[[NSMutableArray alloc] init];
    }
    return _statusFriendArr;
}

-(NSMutableArray *)statusSendRequestArr{
    if (!_statusSendRequestArr) {
        _statusSendRequestArr=[[NSMutableArray alloc] init];
    }
    return _statusSendRequestArr;
}

-(NSMutableArray *)statusPendRequestArr{
    if (!_statusPendRequestArr) {
        _statusPendRequestArr=[[NSMutableArray alloc] init];
    }
    return _statusPendRequestArr;
}

-(NSMutableArray *)friendStatusList{
    if (!_friendStatusList) {
        _friendStatusList=[[NSMutableArray alloc] init];
    }
    return _friendStatusList;
}

-(NSMutableArray *)searchList{
    if (!_searchList) {
        _searchList=[[NSMutableArray alloc] init];
    }
    return _searchList;
}
-(NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList=[[NSMutableArray alloc] init];
    }
    return _dataList;
}
-(NSMutableString *)idSet{
 
    if (!_idSet) {
        _idSet=[[NSMutableString alloc] init];
    }
    return _idSet;
}

-(NSMutableDictionary *)conversationDic{
    if (!_conversationDic) {
        _conversationDic=[[NSMutableDictionary alloc] init];
    }
    return _conversationDic;
}
//
//-(void)getFriendListEventComplete:(void(^)(NSArray *responseObj))success fail:(void(^)(id error))fail{
//    //获取所有好友IDS
//    LRWeakSelf(self);
//    [self.idSet setString:@""];
//    [self.conversationDic removeAllObjects];
//    NSString *urlStr = KGetConnList;
//    [[IMKXAFNetTool shared] post:urlStr parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
//    } success:^(id responseObj) {
//        NSArray *connArr=[responseObj objectForKey:@"connections"];
//        for (NSInteger i=0; i<connArr.count; i++) {
//            NSDictionary *item=[connArr objectAtIndex:i];
//            NSString *status=[item objectForKey:@"status"];
//            NSString *to=[[item objectForKey:@"to"] stringByAppendingString:@","];
//            //
//            if ([status containsString:@"accepted"]) {
//                [weakself.idSet appendString:to];
//                [weakself.conversationDic setObject:[item objectForKey:@"conversation"] forKey:[item objectForKey:@"to"]];
//            }
//        }
//        //获取好友列表
//        if (!(self.idSet.length>0)) {
//            success(@[]);
//            return ;
//        }
//
//        NSRange deleteRange = { [self.idSet length] - 1, 1 };
//        [weakself.idSet deleteCharactersInRange:deleteRange]; // 获取所有好友ID
//        NSString *  getFriendUrl =[@"https://web3.imkexin.com/users?ids=" stringByAppendingString:self.idSet];
//        [[IMKXAFNetTool shared] post:getFriendUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
//        } success:^(id responseObj) {
//            [weakself.dataList removeAllObjects];
//            NSArray *resultArr=responseObj;
//            if (resultArr.count>0) {
//                for (NSDictionary *item in resultArr) {
//                    [weakself.dataList addObject:item];
//                }
//            }
//            [weakself getFriendListEvent:success fail:fail];
//        } failure:^(id error) {
//            fail(error);
//        }];
//    } failure:^(id error) {
//        fail(error);
//    }];
//}


-(void)getFriendListEventComplete:(void(^)(NSArray *responseObj))success fail:(void(^)(id error))fail{
    //显示好友列表
    LRWeakSelf(self);
    [self.idSet setString:@""];
    [self.conversationDic removeAllObjects];
    NSString *urlStr = KGetConnList;
//    @{@"size":@100,@"start":[IMKXConstObject shared].userInfo.userId}
    [[IMKXAFNetTool shared] post:urlStr parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSArray *connArr=[responseObj objectForKey:@"connections"];
        for (NSInteger i=0; i<connArr.count; i++) {
            NSDictionary *item=[connArr objectAtIndex:i];
            NSString *status=[item objectForKey:@"status"];
            NSString *to=[[item objectForKey:@"to"] stringByAppendingString:@","];
            //
            if ([status containsString:@"accepted"]) {
                [self.idSet appendString:to];
                [self.conversationDic setObject:[item objectForKey:@"conversation"] forKey:[item objectForKey:@"to"]];
            }
        }
        //获取好友列表
        if (!(self.idSet.length>0)) {
            success(@[]);
            return ;
        }
        NSRange deleteRange = { [self.idSet length] - 1, 1 };
        [self.idSet deleteCharactersInRange:deleteRange]; // 获取所有好友ID
        NSString *  getFriendUrl =[@"https://web3.imkexin.com/users?ids=" stringByAppendingString:self.idSet];
        [[IMKXAFNetTool shared] post:getFriendUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
        } success:^(id responseObj) {
            [self.dataList removeAllObjects];
            NSArray *resultArr=responseObj;
            if (resultArr.count>0) {
                for (NSDictionary *item in resultArr) {
                    NSMutableDictionary *enableItem =[NSMutableDictionary dictionaryWithDictionary:item];
                    NSString *itemId =[item objectForKey:@"id"];
                    [enableItem setObject:[weakself.conversationDic objectForKey:itemId] forKey:@"cnvId"];
                    [self.dataList addObject:enableItem];
                }
            }
            success(weakself.dataList);
        } failure:^(id error) {
            fail(error);
        }];
    } failure:^(id  error) {
        fail(error);
    }];
}

//搜索好友
-(void)searchFriendListEventByText:(NSString *)searchText complete:(void(^)(NSArray *responseObj))success fail:(void(^)(id error))fail{
    LRWeakSelf(self);
    
    NSString *urlStr = KGetConnList;
    //    @{@"size":@100,@"start":[IMKXConstObject shared].userInfo.userId}
    [[IMKXAFNetTool shared] post:urlStr parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSLog(@"search Success========");
        [weakself.friendStatusList removeAllObjects];
        [weakself.statusSendRequestArr removeAllObjects];
        [weakself.statusPendRequestArr removeAllObjects];
        [weakself.statusNormalAddFriendArr removeAllObjects];
         NSArray *connArr=[responseObj objectForKey:@"connections"];
        for (NSInteger i=0; i<connArr.count; i++) {
            NSDictionary *item=[connArr objectAtIndex:i];
            NSString *status=[item objectForKey:@"status"];
            NSString *to=[item objectForKey:@"to"];
            //
            if ([status containsString:@"accepted"]) {
                [weakself.friendStatusList addObject:to];
            }
            else if([status containsString:@"sent"]){
                [weakself.statusSendRequestArr addObject:to];
            }
            else if([status containsString:@"pend"]){
                [weakself.statusPendRequestArr addObject:to];
            }
//            else{
//                [weakself.statusNormalAddFriendArr addObject:to];
//            }
            //搜索
                NSString *searchUrl=[@"https://web3.imkexin.com/search/contacts?" stringByAppendingFormat:@"size=%d&q=%@",100,searchText];
                [[IMKXAFNetTool shared] post:searchUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
                } success:^(id responseObj) {
                    [weakself.searchList removeAllObjects];
                    NSArray *document=[responseObj objectForKey:@"documents"];
                    if (document.count>0) {
                        for (NSDictionary *item in document) {
                            NSMutableDictionary *enableItem =[[NSMutableDictionary alloc] initWithDictionary:item];
                            NSString *searchId=[enableItem objectForKey:@"id"];
                          
                              if([weakself.friendStatusList containsObject:searchId]){
                                 [enableItem setObject:@"accepted" forKey:@"status"];
                            }
                            else if([weakself.statusSendRequestArr containsObject:searchId]){
                             [enableItem setObject:@"sent" forKey:@"status"];
                                 }
                            else if([weakself.statusPendRequestArr containsObject:searchId]){
                                [enableItem setObject:@"pend" forKey:@"status"];
                            }
                            
                            else {
                                [enableItem setObject:@"normal" forKey:@"status"];
                            }
                            
                            [weakself.searchList addObject:enableItem];
                        }
                    }
                    success(weakself.searchList);
                } failure:^(id error) {
                    fail(error);
                }];
            
        }
        
    } failure:^(id error) {
        fail(error);
    }];
 
    
 
}

//查看群成员 /通过群ID
-(void)selectGroupMemberByGroupId:(NSString *)groupId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *urlStr = KGroupMenber;
    NSString *appUrl = [urlStr stringByAppendingString:groupId];
    [[IMKXAFNetTool shared] post:appUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
        
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
    
}
//添加群成员
-(void)addGroupMemberByGroupId:(NSString *)groupId addMemberList:(NSArray *)memberList complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *urlStr = KAddMember;
    NSString *s = [[urlStr stringByAppendingString:groupId] stringByAppendingString:@"/members"];
    [[IMKXAFNetTool shared] post:s parameters:@{@"users":memberList} httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}
//删除群成员
-(void)deleteGroupMemberByGroupId:(NSString *)groupId deleteMember:(NSString *)memberId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *urlStr = KAddMember;
    urlStr = [[[urlStr stringByAppendingString:groupId] stringByAppendingString:@"/members/"] stringByAppendingString:memberId];
    [[IMKXAFNetTool shared] post:urlStr parameters:@{} httpMethod:@"DELETE" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}






@end
