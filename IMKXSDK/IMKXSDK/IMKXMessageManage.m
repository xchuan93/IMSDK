//
//  IMKXMessageManage.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXMessageManage.h"
#import "IMKXAFNetTool.h"
#import "IMKXConstObject.h"
#import "IMKXUserInterFace.h"
#import "IMKXToolHelper.h"
#import "PrekeyModel.h"
#import <IMKXSDK/IMKXSDK-Swift.h>
#import <AFNetworking/AFNetworking.h>
#import "MessageStatu.h"
#import "UTF8Class.h"

#define KSinceKey @"IMKXSincekey"
#define Kboundary @"frontier"
@interface IMKXMessageManage()
{
    NSInteger once;
}
@property (nonatomic,strong)id receiveClientInfo;
@property (nonatomic,strong)NSMutableDictionary *registerClientDic;  //单聊 注册设备
@property (nonatomic,strong)NSMutableDictionary *receiveClientDic;  //单聊 接收设备
@property (nonatomic,strong)NSString *sendMsgUrl;
@property (nonatomic,strong)id response;
@property (nonatomic,strong)NSMutableDictionary *groupRegisterClient;       //群组注册设备
@property (nonatomic,strong)NSMutableDictionary *groupReceiveClient;    //群组接收设备
@property (nonatomic,assign)NSInteger sumCount;

@property (nonatomic,strong)NSMutableDictionary *groupRecipients;   //群组设备字典

@property (nonatomic,strong)NSString *sendId; //发送者ID


@property (nonatomic,strong)NSMutableDictionary * userWrapper; //group发送

//更改
@property (nonatomic, strong) IMKXUserClientKeysStore * preKey;
@property (nonatomic, strong) NSMutableArray *hexItem;
@property (nonatomic, strong) NSMutableDictionary *textLibrary;

@end

@implementation IMKXMessageManage

//static NSMutableDictionary *groupReceiveClient;

-(NSMutableDictionary *)userWrapper{
    if (!_userWrapper) {
        _userWrapper=[[NSMutableDictionary alloc] init];
    }
    return _userWrapper;
}

-(NSMutableDictionary *)groupRegisterClient{
    if (!_groupRegisterClient) {
        _groupRegisterClient=[[NSMutableDictionary alloc] init];
    }
    return _groupRegisterClient;
}


-(NSMutableDictionary *)groupRecipients{
    if (!_groupRecipients) {
        _groupRecipients=[[NSMutableDictionary alloc] init];
    }
    return _groupRecipients;
}

-(NSMutableDictionary *)groupReceiveClient{
    if (!_groupReceiveClient) {
        _groupReceiveClient=[[NSMutableDictionary alloc] init];
    }
    return _groupReceiveClient;
}


-(NSMutableDictionary *)registerClientDic{
    if(!_registerClientDic){
        _registerClientDic =[[NSMutableDictionary alloc] init];
    }
    return _registerClientDic;
}

-(NSMutableDictionary *)receiveClientDic{
    if(!_receiveClientDic){
        _receiveClientDic=[[NSMutableDictionary alloc] init];
    }
    return _receiveClientDic;
}

- (NSMutableDictionary *)textLibrary{
    if (!_textLibrary) {
        _textLibrary = @{@"0":@"\n$",@"1":@"\x12\x03\n\x01",@"2":@"\x12\x04\n\x02",@"3":@"\x12\x05\n\x03",@"4":@"\x12\x06\n\x04",@"5":@"\x12\x07\n\x05",@"6":@"\x12\x08\n\x06",@"7":@"\x12\t\n\a",@"8":@"\x12\n\n\b",@"9":@"\x12\v\n\t",@"10":@"\x12\f\n\n",@"11":@"\x12\r\n\v",@"12":@"\x12\x0e\n\f0",@"13":@"\x12\x0f\n\r",@"14":@"\x12\x10\n\x0e",@"15":@"\x12\x11\n\x0f",@"16":@"\x12\x12\n\x10",@"17":@"\x12\x13\n\x11",@"18":@"\x12\x14\n\x12",@"19":@"\x12\x15\nx13",@"20":@"\x12\x16\nx14",@"21":@"\x12\x17\n\x15",@"22":@"\x12\x18\n\x16",@"23":@"\x12\x19\n\x17",@"24":@"\x12\x1a\n\x18",@"25":@"\x12\x1b\n\x19",@"26":@"\x12\x1c\n\x1a",@"27":@"\x12\x1d\n\x1b",@"28":@"\x12\x1e\n\x1c",@"29":@"\x12\x1f\n\x1d",@"30":@"\x12\n\x1e",@"31":@"\x12!\n\x1f",@"32":@"\x12\''\n",@"33":@"\x12#\n!",@"34":@"\x12$\n\''"}.mutableCopy;
        [self testaciicode];
    }
    return _textLibrary;
}

- (void)testaciicode{
    NSString *hexprefixCode = @"\x12";
    NSString *hexsuffixCode = @"\n";
    for (int i = 37; i < 0x7c; i++) {
        NSString *asciiprefix = [NSString stringWithFormat:@"%c",i];
        NSString *asciisuffix = [NSString stringWithFormat:@"%c",(i - 2)];
        NSString *appCode = [NSString stringWithFormat:@"%@%@%@%@",hexprefixCode,asciiprefix,hexsuffixCode,asciisuffix];
        [_textLibrary setObject:appCode forKey:@(i-2).stringValue];
    }
}

- (NSMutableArray *)testMessageSpin:(NSString *)str{
    
    NSData *byte_data = [str dataUsingEncoding:NSUTF8StringEncoding];
    Byte * myByte = (Byte *)[byte_data bytes];
    NSInteger length_data = byte_data.length;
    NSInteger moreCode = length_data % 0x78;
    NSInteger errCode = (((length_data/0x78)&&moreCode)) ? (length_data/0x78)+1 : (length_data/0x78);
    if (length_data < 0x78) {
        errCode = 1;
    }
    NSMutableArray *splitArr = @[].mutableCopy;
    for (int i = 0; i < errCode; i++) {
        if ((moreCode && errCode == 1) || (!moreCode &&errCode == 1)) {
            [splitArr addObject:str];
        }else if (!moreCode && errCode > 1){
            Byte dest[200] = {""};
            strncpy(dest, myByte+i*0x78, 0x78);
            NSData *data_byte = [NSData dataWithBytes:dest length:(0x78)];
            NSString *splitStr = [UTF8Class utf8String:data_byte];
            [splitArr addObject:splitStr];
        }else if (moreCode && errCode > 1){
            if (i == (errCode -1)) {
                Byte dest[200] = {""};
                strncpy(dest, myByte+i*0x78, moreCode);
                NSData *data_byte = [NSData dataWithBytes:dest length:moreCode];
                NSString *splitStr = [UTF8Class utf8String:data_byte];
                [splitArr addObject:splitStr];
            }else{
                Byte dest[200] = {""};
                strncpy(dest, myByte+i*0x78, 0x78);
                NSData *data_byte = [NSData dataWithBytes:dest length:(0x78)];
                NSString *splitStr = [UTF8Class utf8String:data_byte];
                [splitArr addObject:splitStr];
            }
        }
    }
    return splitArr;
}

- (NSString *)loadPlistFile:(NSString *)messageid content:(NSString *)content{
    NSData *bytedata = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger bytelen = bytedata.length;
    NSString *header = self.textLibrary[@"0"];
    NSString *errorCode = @"12131920303234";
    if ([errorCode containsString:@(bytelen).stringValue]) {
        ++bytelen;
        content = [content stringByAppendingString:@" "];
        if (bytelen == 0x0c || bytelen == 0x14) {
            ++bytelen;
            content = [content stringByAppendingString:@" "];
        }
    }
    NSString *escapeCharacter = self.textLibrary[@(bytelen).stringValue];
    NSString *encrytext = [NSString stringWithFormat:@"%@%@%@%@",header,messageid,escapeCharacter,content];
    return encrytext;
}


+(instancetype) defaultManage{
    static IMKXMessageManage * manager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =[[IMKXMessageManage alloc] init];
    });
    
    return manager;
}

-(void)getEmjPicByType:(EmojiType)emjType complete:(void(^)(NSArray * emjArr))success{
    NSString *emjName=@"emj_travel";
    if (emjType==emjPeople) {
        emjName=@"emj_people";
    }
    else if(emjType==emjSymbols){
        emjName=@"emj_symbols";
    }
    else if(emjType==emjFood){
        emjName=@"emj_food";
    }
    else if(emjType==emjFlags){
        emjName=@"emj_flags";
    }
    else if(emjType==emjObjects){
        emjName=@"emj_objects";
    }
    else if(emjType==emjActivities){
        emjName=@"emj_activities";
    }
    else if(emjType==emjNature){
        emjName=@"emj_nature";
    }
    NSString *bundlePath= [[NSBundle mainBundle] pathForResource:@"IMKXBundle" ofType:@"bundle"];
    NSString *path=[bundlePath stringByAppendingPathComponent:[emjName stringByAppendingString:@".plist"]];
    NSArray *emjArr=[NSArray arrayWithContentsOfFile:path];
    success(emjArr);
}
-(void)sendMsgByCnvId:(NSString *)cnvId  receiveId:(NSString *)recId msgContet:(id)content complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
   
    LRWeakSelf(self);
    NSString *sendId = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    if (sendId==nil) {
//        NSLog(@"sendMsgByCnvIdsendId为nil");
        fail(@"sendId为nil");
        return;
    }
    
    self.sendMsgUrl=[NSString stringWithFormat:@"https://web3.imkexin.com/conversations/%@/otr/messages",cnvId];
    
    //获取用户的client
    NSString *getUserClientUrl=  [NSString stringWithFormat:@"https://web3.imkexin.com/users/%@/clients",recId];
    [[IMKXAFNetTool shared] post:getUserClientUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        self.receiveClientInfo=responseObj;
        
        NSMutableArray *splitItem = [self testMessageSpin:content];
        for (NSString *splitStr in splitItem) {
 
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                   [weakself sendMsgByClient:responseObj receiveId:recId msgContent:splitStr success:success fail:fail];
                });
            });
            
            
        }
//        NSLog(@"222");
        
    } failure:^(NSString *error) {
//        NSLog(@"111");
        fail(error);
    }];
 
}

- (void)sendMsgByClient:(id)recClientInfo receiveId:(NSString *)recId msgContent:(id)content success:(void(^)(id response))success fail:(void(^)(id error))fail{

    [[MessageStatu sharedOneTimeClass] setMessagestatu:YES];
    NSUUID *nonce = NSUUID.UUID;
    NSString *str_uuid = [[nonce UUIDString] lowercaseString];
    NSString *str_uuid_a = [self loadPlistFile:str_uuid content:content];
    NSData *data_64 = [str_uuid_a dataUsingEncoding:NSUTF8StringEncoding];
    self.preKey = [IMKXUserClientKeysStore sharedInstance];
    if (!IMKXUserClientKeysStore.encryptionContext) {
        [IMKXUserClientKeysStore setUp];
    }
    NSString *sendId = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    
//    NSLog(@"sendMsgByClient---userId%@",userId);
    
    NSMutableArray *senderItem = @[].mutableCopy;
    NSMutableArray *recipItem = @[].mutableCopy;
    [self.registerClientDic removeAllObjects];
    [self.receiveClientDic removeAllObjects];
    
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSString *str = @"https://web3.imkexin.com/users/";
    NSString *url = [[str stringByAppendingString:recId] stringByAppendingString:@"/prekeys"];
    [[IMKXAFNetTool shared] post:url parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSArray *clientsArr = responseObj[@"clients"];
        for (NSDictionary *clientDic in clientsArr) {
            ClientPrekeyModel *model = [[ClientPrekeyModel alloc] initWithDictionary:clientDic error:nil];
            [recipItem addObject:model];
        }
        dispatch_group_leave(group);
    } failure:^(NSString *error) {
    }];
    dispatch_group_enter(group);
    NSString *url1 = [[str stringByAppendingString:userId] stringByAppendingString:@"/prekeys"];
    [[IMKXAFNetTool shared] post:url1 parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSArray *clientsArr = responseObj[@"clients"];
        for (NSDictionary *clientDic in clientsArr) {
            ClientPrekeyModel *model = [[ClientPrekeyModel alloc] initWithDictionary:clientDic error:nil];
            [senderItem addObject:model];
        }
        dispatch_group_leave(group);
    } failure:^(NSString *error) {
        fail(error);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for (ClientPrekeyModel *model in recipItem) {
            if ([model.client isEqualToString:sendId]) {
                continue ;
            }
            NSString *base_64 = [NSString stringWithFormat:@"%@_%@",recId,model.client];
            NSString *encry_message = [IMKXUserClientKeysStore establishEncryptSessionWithPlainText:data_64 prekey:model.prekey.key identifier:base_64];
            [self.receiveClientDic setObject:encry_message forKey:model.client];
        }
        for (ClientPrekeyModel *model in senderItem) {
            if ([model.client isEqualToString:sendId]) {
                continue ;
            }
            NSString *base_64 = [NSString stringWithFormat:@"%@_%@",userId,model.client];
            NSString *encry_message = [IMKXUserClientKeysStore establishEncryptSessionWithPlainText:data_64 prekey:model.prekey.key identifier:base_64];
            [self.registerClientDic setObject:encry_message forKey:model.client];
        }
        NSDictionary *recipParam = @{
                                     userId:self.registerClientDic,
                                     recId:self.receiveClientDic
                                     };
        NSDictionary *param=@{@"native_priority":@"high",@"data":@"Data",@"native_push":@(YES),@"sender":sendId,@"transient":@(YES),@"recipients":recipParam};
        
//        NSLog(@"recipParam====%@",recipParam);
        
        [[IMKXAFNetTool shared] post:self.sendMsgUrl parameters:param httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
        } success:^(id responseObj) {
            success(responseObj);
        } failure:^(id error) {
            fail(error);
        }];
    });
}
//发送群组消息
-(void)sendGroupMsgByGroupId:(NSString *)groupId msgContet:(id)content complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
     //获取当前group 用户
    LRWeakSelf(self);
    NSString *urlStr = KGroupMenber;
    NSString *appUrl = [urlStr stringByAppendingString:groupId];
    [[IMKXAFNetTool shared] post:appUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
 
    } success:^(id responseObj) {
 
        NSMutableArray *splitItem = [self testMessageSpin:content];
        NSLog(@"sendGroupMSgCount ===%ld",splitItem.count);
        for (NSString *splitStr in splitItem) {
 
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself sendGroupMSg:responseObj groupId:groupId content:splitStr complete:success fail:fail];
                });
            });
        }
        
        
    } failure:^(id error) {
        fail(error);
    }];
    
   
}


-(void)sendGroupMSg:(id) response groupId:(NSString *)groupId content:(NSString *)content complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    LRWeakSelf(self);
 
    [[MessageStatu sharedOneTimeClass] setMessagestatu:YES];
    NSLog(@"sendGroupMSg === %@",@([MessageStatu sharedOneTimeClass].messageStatu));
    NSUUID *nonce = NSUUID.UUID;
    NSString *str_uuid = [[nonce UUIDString] lowercaseString];
    NSString *str_uuid_a = [self loadPlistFile:str_uuid content:content];
    NSData *data_64 = [str_uuid_a dataUsingEncoding:NSUTF8StringEncoding];
    self.preKey = [IMKXUserClientKeysStore sharedInstance];
    if (!IMKXUserClientKeysStore.encryptionContext) {
        [IMKXUserClientKeysStore setUp];
    }
    
    
    NSMutableArray *senderItem = @[].mutableCopy;
    NSMutableArray *recipItem = @[].mutableCopy;
    
    [self.groupReceiveClient removeAllObjects];
    [self.groupRegisterClient removeAllObjects];
    [self.userWrapper removeAllObjects];
    
        NSString *sendId = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    self.sendMsgUrl=[NSString stringWithFormat:@"https://web3.imkexin.com/conversations/%@/otr/messages",groupId];
    
   NSArray *membersArr =[[[[response objectForKey:@"conversations"]firstObject] objectForKey:@"members"] objectForKey:@"others"];//群成员数组
 
    // 创建队列组，可以使多个网络请求异步执行，执行完之后再进行操作
   NSString *str = @"https://web3.imkexin.com/users/";
    if ([membersArr count]>0) {
        dispatch_group_t group = dispatch_group_create();
        __block NSInteger i = 0 ;
       
        // 循环上传数据
 
        for (NSDictionary *memItem in membersArr){
          dispatch_group_enter(group);
          //encrypted
            NSString *memUserId=[memItem objectForKey:@"id"];
            NSString *url1 = [[str stringByAppendingString:[memItem objectForKey:@"id"]] stringByAppendingString:@"/prekeys"];
            [[IMKXAFNetTool shared] post:url1 parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
            } success:^(id responseObj) {
                NSArray *clientsArr = responseObj[@"clients"];
                for (NSDictionary *clientDic in clientsArr) {
                    NSMutableDictionary *clientItemDic=[NSMutableDictionary dictionaryWithDictionary:clientDic];
                    [clientItemDic setObject:memUserId forKey:@"userId"];
                    [recipItem addObject:clientItemDic];
                }
                
                 i++;
                dispatch_group_leave(group);
                
            } failure:^(NSString *error) {
                fail(error);
            }];

        }

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            
//            NSLog(@"dispatch_group_notify==============");
            //encrypted
            
            NSString *loginUserId=[IMKXConstObject shared].userInfo.userId;
            NSString *str = @"https://web3.imkexin.com/users/";
            NSString *url = [[str stringByAppendingString:loginUserId] stringByAppendingString:@"/prekeys"];
            [[IMKXAFNetTool shared] post:url parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
            } success:^(id responseObj) {
                
                NSArray *clientsArr = responseObj[@"clients"];
                for (NSDictionary *clientDic in clientsArr) {
                    ClientPrekeyModel *model = [[ClientPrekeyModel alloc] initWithDictionary:clientDic error:nil];
//                    [IMKXConstObject shared].sendId = model.client;
                    [senderItem addObject:model];
                }
                
                
                //接受者拼接
                for (NSDictionary *model in recipItem) {
                    
                    NSString *modelUserId=[model objectForKey:@"userId"];
                    NSString *modelClient=[model objectForKey:@"client"];
                    
                    if ([modelClient isEqualToString:sendId]) {
                        continue ;
                    }
                    
                    
                    NSString *base_64 = [NSString stringWithFormat:@"%@_%@",modelUserId ,modelClient];
                    NSString *preKeyIden =[[model objectForKey:@"prekey"] objectForKey:@"key"];
                    NSString *encry_message = [IMKXUserClientKeysStore establishEncryptSessionWithPlainText:data_64 prekey:preKeyIden identifier:base_64];
                    [weakself.groupReceiveClient setObject:encry_message forKey:modelClient];
 
                    [weakself.userWrapper setObject:weakself.groupReceiveClient forKey:[model objectForKey:@"userId"]];
                    
                    [weakself.groupRecipients setObject:weakself.userWrapper forKey:@"recipients"];
                }
                
                //发送者拼接
                for (ClientPrekeyModel *model in senderItem) {
                    if ([model.client isEqualToString:sendId]) {
                        continue ;
                    }
                    NSString *userId=[IMKXConstObject shared].userInfo.userId;
                    NSString *base_64 = [NSString stringWithFormat:@"%@_%@",userId,model.client];
                    NSString *encry_message = [IMKXUserClientKeysStore establishEncryptSessionWithPlainText:data_64 prekey:model.prekey.key identifier:base_64];
                    [weakself.groupRegisterClient setObject:encry_message forKey:model.client];
                    [weakself.userWrapper setObject:weakself.groupRegisterClient forKey:[IMKXConstObject shared].userInfo.userId];
 
                }
 
                NSString *clientid = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
                    [weakself.groupRecipients setObject:@(YES) forKey:@"native_push"];
                    [weakself.groupRecipients setObject:clientid forKey:@"sender"];
                
                
                NSLog(@"sendGroupMSg=====%@",weakself.groupRecipients);
                
                    self.sendMsgUrl=[NSString stringWithFormat:@"https://web3.imkexin.com/conversations/%@/otr/messages",groupId];
                    [[IMKXAFNetTool shared] post:self.sendMsgUrl parameters:weakself.groupRecipients httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
                    } success:^(id responseObj) {
                        success(responseObj);
                    } failure:^(id error) {
                        fail(error);
                    }];
               
                
                //end
                
            } failure:^(NSString *error) {
                fail(error);
            }];
            
            //end
            
         
         });
    }
}
-(void)getOffLineMessageComplete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *sendId=[[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    NSString *since=KGetIMKXUser(KLastNotiKey);
    if (!since||since==nil) {
        since=@"";
        NSLog(@"离线消息since===nil");
        fail(@"since 为null===");
    }
    NSString *lastNotKey= KGetIMKXUser(KLastNotiKey);
    NSLog(@"lastNotkey==========%@",lastNotKey);
    NSString *fetchNotiUrl =[KFetchNotiUrl stringByAppendingFormat:@"/%@?client=%@",lastNotKey,sendId];
    fetchNotiUrl=KFetchNotiUrl;
    NSDictionary *param=@{@"id":lastNotKey,@"client":sendId};
    [[IMKXAFNetTool shared] post:fetchNotiUrl parameters:param httpMethod:@"get" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        if (responseObj) {
            NSArray *notiArr=[responseObj objectForKey:@"notifications"];
            NSDictionary *lastNotiObj=[notiArr lastObject];
            NSString *lastNotiKey= [lastNotiObj objectForKey:@"id"];
            KSetIMKXUser(lastNotiObj, KSinceKey);  //保存下次NotiKey
            //遍历
            for (NSDictionary *item  in notiArr) {
                NSDictionary *notiContent =[[item objectForKey:@"payload"] firstObject];
                NSString *notiType = [notiContent objectForKey:@"type"];
                if ([notiType containsString:@"user.client-"]) {
                    continue;
                }
                //消息
                if ([notiType containsString:@"conversation.otr-message-add"]) {
                    
                    NSMutableDictionary *containDic=[[NSMutableDictionary alloc] initWithDictionary:[notiContent objectForKey:@"data"]];
                    NSString *encryText=[containDic objectForKey:@"text"];
                    NSString *normalText =[self publicDecryptionByUserId:IMKXConstObject.shared.userInfo.userId clientId:sendId encryText:encryText];  //获取解密文本
                    
                    NSLog(@"normalText=========%@",normalText);
                    //                         [containDic setObject:normalText forKey:@"text"];
                    
                }
                
                
            }
            
            
        }
        
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}


-(NSString *)publicDecryptionByUserId:(NSString *)userId clientId:(NSString *)clientId encryText:(NSString *)text{
    
    
    
    self.preKey = [IMKXUserClientKeysStore sharedInstance];
    if (!IMKXUserClientKeysStore.encryptionContext) {
        [IMKXUserClientKeysStore setUp];
    }
    //    NSData *data_decry64 = [IMKXUserClientKeysStore decryptWithIdentifier:clientStr prekeyMessage:data64];
    NSString *clientStr = [NSString stringWithFormat:@"%@_%@",userId,clientId];
    NSLog(@"clientStr=======%@ ",clientStr);
    NSData* data64 = [[NSData alloc] initWithBase64EncodedString:text options:0];
    self.preKey = [IMKXUserClientKeysStore sharedInstance];
    if (!IMKXUserClientKeysStore.encryptionContext) {
        [IMKXUserClientKeysStore setUp];
    }
    NSData *data_decry64 = [IMKXUserClientKeysStore decryptWithIdentifier:clientStr prekeyMessage:data64];
    
    NSLog(@"data_decry64===========%@",data_decry64);
    NSString *str_decry64 = [data_decry64 base64EncodedStringWithOptions:0];
    NSLog(@"str_decry64 1111====   %@",str_decry64);
    NSData *data_decry_64 = [[NSData alloc] initWithBase64EncodedString:str_decry64 options:0];
    Byte *byte_test = data_decry_64.bytes;
    NSString *str_decry_64 = [[NSString alloc] initWithData:data_decry_64 encoding:NSUTF8StringEncoding];
    if (!str_decry_64) {
        str_decry_64 = [UTF8Class utf8String:data_decry_64];
    }
    NSInteger count = data_decry_64.length - 42;
    NSString *sas = [NSString stringWithFormat:@"-----%@",@(count).stringValue];
    __unused NSString *asd = [str_decry_64 stringByAppendingString:sas];
    NSArray *splitArr = [str_decry_64 componentsSeparatedByString:@"\n"];
    NSString *split_str = splitArr.lastObject;
    NSData* bytes = [split_str dataUsingEncoding:NSUTF8StringEncoding];
    Byte *xcByte = split_str.UTF8String;
    if (!str_decry_64 || str_decry64.length <= 0) {
        NSLog(@"str_decry_64====%@",str_decry_64);
        return nil;
    }
    Byte dest[1000000] = {0};
    strncpy(dest, xcByte+1, strlen(xcByte)-1);
    NSData *data_byte = [NSData dataWithBytes:dest length:(strlen(xcByte) -1)];
    NSString *str = [[NSString alloc] initWithData:data_byte encoding:NSUTF8StringEncoding];
    if (!str) {
        str = [UTF8Class utf8String:data_byte];
    }
    if ([str_decry_64 containsString:@"\n\n"] && bytes.length == 0x0a) {
        str = split_str;
    }
    return str;
    
}


-(void)getPushMsgByNotificationId:(NSString *)notiId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail;{
 
    NSString *client=KGetIMKXUser(KCurrentClientKey);
    NSString *notiUrl=[KFetchNotiUrl stringByAppendingString: [NSString stringWithFormat:@"/%@?client=%@",notiId,client]];
    
    [[IMKXAFNetTool shared]post:notiUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
        
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
    
    
}

#pragma Mark SendFile
-(void)sendFile:(NSData *)fileData cnvId:(NSString *)cnvId  receiveId:(NSString *)recId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    LRWeakSelf(self);
    [self uploadFileByData:fileData complete:^(id responseObj) {
        //文件上传成功
        NSString *assetKey=[responseObj objectForKey:@"key"];
        NSString *assetToken=[responseObj objectForKey:@"token"];
        //拼接发送文本
        
        //        NSString *downUrl=[assetKey stringByAppendingString:assetToken];
        NSString *downUrl=  [KUploadAssetUrl stringByAppendingFormat:@"%@?access_token=%@&asset_token=%@&forceCaching=true",assetKey,[IMKXConstObject shared].constToken,assetToken];
//        NSLog(@"downUrl========%@",downUrl);
        
        [weakself sendMsgByCnvId:cnvId receiveId:recId msgContet:downUrl complete:^(id responseObj) {
            success(responseObj);
        } fail:^(id error) {
            fail(error);
        }];
        
        
    } fail:^(id error) {
        fail(error);
    }];
    
    
}




-(void)uploadFileByData:(NSData *)fileData  complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain", nil];
    NSString *uploadUrl= KUploadAssetUrl;
    NSURL *url=[NSURL URLWithString:uploadUrl];
    //2.2创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //2.3 设置请求方法
    request.HTTPMethod = @"POST";
    [request setValue:[@"Bearer " stringByAppendingString:[IMKXConstObject shared].constToken] forHTTPHeaderField:@"Authorization"];
    //2.4 设请求头信息
    [request setValue:[NSString stringWithFormat:@"multipart/mixed; boundary=%@",Kboundary] forHTTPHeaderField:@"Content-Type"];
    // 发送请求上传文件
    NSURLSessionUploadTask *uploadTask=[manager uploadTaskWithRequest:request fromData:[self getBodyData:fileData] progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadFile============%f",1.0 * uploadProgress.completedUnitCount/ uploadProgress.totalUnitCount);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                id resDic= [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                
//                NSLog(@"responseObj=======%@",resDic);
                success(resDic);
            }
            else if([responseObject isKindOfClass:[NSString class]]){
                
                NSString *aa=responseObject;
            }
            
        }
        
        if (error) {
            NSDictionary *bbb=  error.userInfo;
 
            NSData* errorUserData=  [bbb objectForKey:@"com.alamofire.serialization.response.error.data"];
            if (!errorUserData||errorUserData==nil) {
                
                return;
            }
            
            NSString *erroMessage=@"";
            id errorDic= [NSJSONSerialization JSONObjectWithData:errorUserData options:NSJSONReadingMutableContainers error:nil];
            if ([errorDic isKindOfClass:[NSDictionary class]]) {
                erroMessage = [errorDic objectForKey:@"message"];
                NSLog(@"IM Server Error======%@",erroMessage);
                
                fail(erroMessage);
            }
            NSLog(@"errorMSG====%@",erroMessage);
        }
        
    }];
    //执行task
    [uploadTask resume];
}
-(NSData *)getBodyData:(NSData *)data{
    NSMutableData *fileData=[NSMutableData data];
    [fileData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[@"Content-Type: application/json; charset=utf-8" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[@"\r\nContent-length: 41\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *dic=@{@"public":@NO,@"retention":@"persistent"};
    NSData *dicData= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dicStr=[[NSString alloc] initWithData:dicData encoding:NSUTF8StringEncoding];
    dicStr= [dicStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    dicStr=[dicStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    [fileData appendData:[dicStr dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[@"Content-Type: application/octet-stream" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[[NSString stringWithFormat:@"\r\nContent-length: %ld\r\n",data.length] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *md5=  [IMKXToolHelper getFileMD5String:data];
    [fileData appendData:[ [NSString stringWithFormat:@"Content-MD5: %@\r\n\r\n",md5] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:data];
    [fileData appendData:[[NSString stringWithFormat:@"\r\n--%@--",Kboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return fileData;
}
@end
