//
//  IMKXUserManage.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "IMKXUserManage.h"
#import "IMKXBaseObject.h"
#import "IMKXToolHelper.h"
#import "IMKXUserInterFace.h"
#import "IMKXConstObject.h"
#import "IMKXAFNetTool.h"
#import "IMKXLoginInfo.h"
#import "IMKXClientModel.h"
#import "IMKXNSData+ZMSCrypto.h"
#import "IMKXSocketRocketUtility.h"
#import "IMKXUserInterFace.h"
#import <WireCryptobox/WireCryptobox.h>
#import <IMKXSDK/IMKXSDK-Swift.h>
#import <AFNetworking/AFNetworking.h>
//#import "NSData+UTF8.h"
#import "UTF8Class.h"
#import "MessageStatu.h"
#import "IMKXUserInterFace.h"
#import <AFNetworking/AFNetworking.h>
#import "IMKXConstObject.h"
#import "PrekeyModel.h"

@interface IMKXUserManage()
@property (nonatomic,strong)NSMutableArray *clientArr;
@property (nonatomic,strong)NSMutableArray *preMutArr;
@property (nonatomic,strong)IMKXClientModel *clientM;
@property (nonatomic,strong)NSMutableArray *registerClientArr;

@property (nonatomic,strong)NSString *userId;

@property (nonatomic,strong)NSString *bundleId;
@property (nonatomic,strong)NSString *pushToken;

//更改
@property (nonatomic, strong) IMKXUserClientKeysStore * preKey;
@property (nonatomic, strong) NSMutableArray *hexItem;

@property (nonatomic,strong)UILocalNotification *locationNoti;
//@property (nonatomic,strong)NSMutableArray *payloadArr;
@property (nonatomic,assign)BOOL NetEnable;
@end


@implementation IMKXUserManage



-(UILocalNotification *)locationNoti{
    
    if (!_locationNoti) {
        _locationNoti=[[UILocalNotification alloc] init];
        _locationNoti.alertAction=@"action";
        NSInteger badgeNum=  [UIApplication sharedApplication].applicationIconBadgeNumber+1;
        _locationNoti.applicationIconBadgeNumber=badgeNum;
        _locationNoti.soundName=@"first_message.caf";
        _locationNoti.fireDate=[NSDate dateWithTimeIntervalSinceNow:0];
    }
    return _locationNoti;
}
- (NSMutableArray *)hexItem{
    if (!_hexItem) {
        _hexItem = [[NSMutableArray alloc] init];
    }
    return _hexItem;
}

-(NSMutableArray *)registerClientArr{
    if (!_registerClientArr) {
        _registerClientArr=[[NSMutableArray alloc] init];
    }
    return _registerClientArr;
}
-(NSMutableArray *)clientArr{
    if (!_clientArr) {
        _clientArr=[[NSMutableArray alloc] init];
    }
    return _clientArr;
}
-(NSMutableArray *)preMutArr {
    if (!_preMutArr) {
        _preMutArr=[[NSMutableArray alloc] init];
    }
    return _preMutArr;
}
+(instancetype) defaultManage{
    static IMKXUserManage * manager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =[[IMKXUserManage alloc] init];
    });
    return manager;
}


-(void)monitorNet{
    LRWeakSelf(self);
AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
[netManager startMonitoring];  //开始监听
[netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
    if (status == AFNetworkReachabilityStatusNotReachable)
    {
        weakself.NetEnable=NO;
    }
    else{
        if (weakself.NetEnable) {
            return ;
        }
        weakself.NetEnable=YES;
        NSString *updateTokenUrl=KUpdateTokenUrl;
        [[IMKXAFNetTool shared] post:updateTokenUrl parameters:@{} httpMethod:@"POST" progress:^(NSProgress * uploadProgress) {
        } success:^(id responseObj) {
            if (responseObj) {
                NSLog(@"token 更新成功=======");
                [IMKXConstObject shared].constToken=[responseObj objectForKey:@"access_token"];
                [IMKXConstObject shared].userInfo.access_token= [responseObj objectForKey:@"access_token"];
                [IMKXConstObject shared].userInfo.token_type= [responseObj objectForKey:@"token_type"];
                [IMKXConstObject shared].userInfo.userId= [responseObj objectForKey:@"user"];
//                [[NSUserDefaults standardUserDefaults] setValue:[responseObj objectForKey:@"user"] forKey:@"userId"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *token=[IMKXConstObject shared].constToken;
                if (!token||token==nil) {
                    return;
                }
                
                [weakself buildSocket:nil fail:nil];
 
            }
        } failure:^(NSString *error) {
            NSLog(@"token 更新失败========");
        }];
    }
}];
}
-(void)initWithEmail:(NSString *)email password:(NSString *)password appkey:(NSString *)appKey bunldId:(NSString *)bundleId token:(NSString *)pushToken complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
     __unused  LRWeakSelf(self);
    NSString *urlStr=KLogin;  //登录
    NSDictionary *param=@{@"email":email,@"password":password,@"appkey":appKey,@"bundleid": bundleId};
    IMKXLoginInfo *loginM=[[IMKXLoginInfo alloc] init];
    loginM.email=email;
    loginM.password=password;
    loginM.appKey=appKey;
    loginM.bundleid=bundleId;
    [IMKXConstObject shared].loginInfo=loginM;
    [[IMKXAFNetTool shared] post:urlStr parameters:param httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSString *accessToken= [responseObj objectForKey:@"access_token"];
        NSString *token_type=[responseObj objectForKey:@"token_type"];
        
        NSString *userId=[responseObj objectForKey:@"user"];
        self.userId=userId;
//        [[NSUserDefaults standardUserDefaults] setValue:self.userId forKey:"xcuserId"];
        IMKXUserInfo *info=[[IMKXUserInfo alloc] init];
        info.access_token=accessToken;
        info.token_type= token_type;
        info.userId= userId;
        info.passWord=password;
 
        [[NSUserDefaults standardUserDefaults] setValue:userId forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
 
        [[IMKXConstObject shared] setUserInfo:info];  //保存登录信息
        [[IMKXConstObject shared] setConstToken:accessToken];
        
        //保存本地token
        KSetIMKXUser(accessToken, KCurrentLoginToken);
        
        weakself.bundleId=bundleId;
        weakself.pushToken=@"12345";
        if (pushToken) {
             weakself.pushToken=pushToken;
        }
       //socket
      [weakself buildSocket:success fail:fail];
    
//      [self registerClients:success fail:fail];
        //创建账号
        NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
////        [IMKXConstObject shared].sendId=clientId;
        if (!clientId) {
            [self registerClients:success fail:fail];
        }
        
    } failure:^(id error) {
        fail(error);
    }];
    
//   [weakself monitorNet]; //监听网络
    
}

-(void)buildSocket:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    //建立socket
    NSString *token=[IMKXConstObject shared].constToken;
    if (!token||token==nil) {
        fail(@"socket token error");
        return;
    }
    [[IMKXSocketRocketUtility instance] SRWebSocketOpenWithURLString:[KSocketUrl stringByAppendingString:token]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpenNote object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketdidReceiveMessageNote object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidClose) name:kWebSocketDidCloseNote object:nil];
    
    NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    if (clientId) {
        KSetIMKXUser(clientId, KCurrentClientKey);  // 保存clientID
        [self getAllClients:success fail:fail];
    }

}

//注册client设备
- (void)registerClients:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    LRWeakSelf(self);
    //SignKey
    SignalingKeys * signlingKeys = [[[IMKXAPSSignalingKeysStore alloc] init] createKeys];
    NSDictionary *signDic = @{@"enckey":[[signlingKeys decryptionKey] base64EncodedStringWithOptions:0],@"mackey":[[signlingKeys verificationKey]base64EncodedStringWithOptions:0]};
    //PreKey
    self.preKey = [IMKXUserClientKeysStore sharedInstance];
    NSMutableArray *preArr= [self.preKey generateMoreKeys:99 start:0];
    NSDictionary *lastKey= [self.preKey lastPreKey];
    
    for (id item in preArr) {
        NSString * key = [item objectForKey:@"id"];
        NSInteger keyInt = [key integerValue];
        NSString *value =[item objectForKey:@"prekey"];
        [self.preMutArr addObject:@{@"id":@(keyInt),@"key":value}];
    }
    NSString *deviceName=KDeviceName;
    IMKXLoginInfo *currentLoginInfo = [IMKXConstObject shared].loginInfo;
    NSDictionary *regParam =@{@"cookie":[IMKXConstObject shared].constCookie,@"prekeys":self.preMutArr,@"model":[IMKXToolHelper deviceModelName] ,@"type":@"permanent",@"password":currentLoginInfo.password,@"class":@"phone",@"label":deviceName, @"lastkey":lastKey,@"sigkeys":signDic};
    
    //Register Client
    [[IMKXAFNetTool shared] post:KRigisterClientsUrl parameters:regParam httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
        
    } success:^(id responseObj) {
        self.clientM =[[IMKXClientModel alloc] initWithDictionary:responseObj error:nil];
        [IMKXConstObject shared].sendId =[[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
        
        /*********/
        weakself.clientM =[[IMKXClientModel alloc] initWithDictionary:responseObj error:nil];
        [IMKXConstObject shared].sendId =self.clientM.clientId;
        KSetIMKXUser(self.clientM.clientId, KCurrentClientKey);  // 保存clientID
        [self getAllClients:success fail:fail];
        /*************/
        
        [[NSUserDefaults standardUserDefaults] setValue:self.clientM.clientId forKey:@"clientId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [IMKXConstObject shared].sendId=self.clientM.clientId;
        //获取最后一次LastNoti
        NSString *currentClient =KGetIMKXUser(@"clientId");
//        [weakself getLastNotificationId:currentClient complete:nil fail:nil];
        
    } failure:^(NSString *error) {
        fail(error);
    }];
}

//获取最后一次
-(void)getLastNotificationId:(NSString *)clientId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    [[IMKXAFNetTool shared] post:KFetchLastNotiUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSString *since=[responseObj objectForKey:@"id"];
        KSetIMKXUser(since, KLastNotiKey);
    } failure:^(id error) {
        fail(error);
    }];
}

//获取ALL CLIENT 保存至本地
-(void)getAllClients:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    LRWeakSelf(self);
    [[IMKXAFNetTool shared] post:KRigisterClientsUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        
        NSLog(@"getAllClients");
        
        [self.registerClientArr removeAllObjects];
        if ([responseObj count]>0) {
            for (NSDictionary *item  in responseObj) {
                [self.registerClientArr addObject:item];
            }
            [IMKXConstObject shared].registerClientArr=self.registerClientArr;
        }
        
        if (!self.userId) {
            
            self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [IMKXConstObject shared].userInfo.userId = self.userId;
        }
        NSLog(@"getAllClients====%@",self.userId);
         success(@{@"userId":self.userId});
        
//        NSLog(@"getAllClients------%@",weakself.userId);
        
//        PUSHKIT推送
     __unused  NSString *bundleID= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *clientid = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
        NSDictionary *pushParam=@{@"app":self.bundleId,@"client":clientid,@"token":self.pushToken,@"transport":@"APNS_VOIP_SANDBOX"};

        [[IMKXAFNetTool shared] post:KRegisterPushTokenUrl parameters:pushParam httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
        } success:^(id responseObj) {

            NSLog(@"注册voip push token 成功");

        } failure:^(id error) {
NSLog(@"注册voip push token 失败");
        }];
       
    } failure:^(id error) {
        fail(error);
    }];
}

- (void)ensureMessageCorrectness:(NSString *)mesage{
    
    NSString *str = @"https://web3.imkexin.com/users/";
    NSString *url = [[str stringByAppendingString:mesage] stringByAppendingString:@"/prekeys"];
    
    [[IMKXAFNetTool shared] post:url parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        NSMutableArray *recipItem = @[].mutableCopy;
        NSArray *clientsArr = responseObj[@"clients"];
        for (NSDictionary *clientDic in clientsArr) {
            ClientPrekeyModel *model = [[ClientPrekeyModel alloc] initWithDictionary:clientDic error:nil];
            NSString *base_64 = [NSString stringWithFormat:@"%@_%@",mesage,model.client];
            NSString *encry_message = [IMKXUserClientKeysStore establishEncryptSessionWithPlainText:[@"123" dataUsingEncoding:NSUTF8StringEncoding] prekey:model.prekey.key identifier:base_64];
        }
    } failure:^(NSString *error) {}];
}

-(void)getUserInfoById:(NSString *)userId complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    NSString *getUserIdUrl =[@"https://web3.imkexin.com/users/" stringByAppendingString:userId];
    [[IMKXAFNetTool shared] post:getUserIdUrl parameters:@{} httpMethod:@"GET" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        success(responseObj);
    } failure:^(id error) {
        fail(error);
    }];
}
-(void)loginOutEventComplete:(void(^)(void))success fail:(void(^)(id error))fail{
    [[IMKXAFNetTool shared] post:KLoginOutUrl parameters:@{} httpMethod:@"POST" progress:^(NSProgress *uploadProgress) {
    } success:^(id responseObj) {
        [[IMKXSocketRocketUtility instance] SRWebSocketClose];
        success();
    } failure:^(id error) {
              [[IMKXSocketRocketUtility instance] SRWebSocketClose];
        fail(error);
    }];
}
#pragma mark Notification
-(void)locationPushByContent:(NSString *)pushContent{
    
    NSLog(@"pushContent=========%@",pushContent);
    UILocalNotification *localNoti=self.locationNoti;
    localNoti.alertBody=pushContent;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNoti];
}

#pragma mark Socket Method
-(void)SRWebSocketDidOpen{
    [self.delegate SocketConnectionOpen];
}
-(void)SRWebSocketDidClose{
    [self.delegate SocketConnectionClose];
}

- (NSString *)decryptMessage:(id)message{
    
    if (!message) {
        return nil;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *arr = dic[@"payload"];
    NSDictionary *data = [arr[0] objectForKey:@"data"];
    NSString *text = data[@"text"];
    NSString *clientid = data[@"recipient"];
    NSString *from = [arr[0] objectForKey:@"from"];
    NSString *clientId_local = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    NSString *sendClient = data[@"sender"];
//    NSLog(@"111from ========%@    sendClient=======%@ clientid======%@ clientId_local=====%@,messageStatu ======%@",from,sendClient,clientid,clientId_local,@([[MessageStatu sharedOneTimeClass] messageStatu]));

    NSMutableDictionary *containDic=[NSMutableDictionary dictionaryWithDictionary:dic];
    NSArray *payArr=[dic objectForKey:@"payload"];
    //判断socket类型
    NSDictionary *payloadContent =[payArr firstObject];
    NSString *socketType=[payloadContent objectForKey:@"type"];
    if (![socketType containsString:@"conversation.otr-message-add"]) {
        [self.delegate SocketDidReceiveMessage:containDic];
        return nil;
    }
    
    if (!from || !text.length) {
        return nil;
    }
    
    NSLog(@"clientId_local====%@   clientid====%@  messageStatu====%@",clientId_local,clientid,@([[MessageStatu sharedOneTimeClass] messageStatu]));
    
    if (![clientId_local isEqualToString:clientid]) {
        
        if ([clientId_local isEqualToString:clientid]) {
            [[MessageStatu sharedOneTimeClass] setMessagestatu:NO];
        }
        NSLog(@"clientid");
        return nil;
    }
    
    [self ensureMessageCorrectness:from];
    
    NSString *clientStr = [NSString stringWithFormat:@"%@_%@",from,sendClient];
    NSData *data64 = [[NSData alloc] initWithBase64EncodedString:text options:0];
    self.preKey = [IMKXUserClientKeysStore sharedInstance];
    if (!IMKXUserClientKeysStore.encryptionContext) {
        [IMKXUserClientKeysStore setUp];
    }
    
    NSData *data_decry64 = [IMKXUserClientKeysStore decryptWithIdentifier:clientStr prekeyMessage:data64];
    
    NSLog(@"abcd-----%@",data_decry64);
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
    NSString *asd = [str_decry_64 stringByAppendingString:sas];
    /*
     添加到数组
     */
    [self.hexItem addObject:asd];
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
    [self receiveMessage:message encrytStr:str];
    return str;
}

-(void)SRWebSocketDidReceiveMsg:(NSNotification *)noti{
    LRWeakSelf(self);
    id message =noti.object;
    NSString *encryText = [self decryptMessage:message];
    
}

- (void)receiveMessage:(id)message encrytStr:(NSString *)encrytStr{
    
    if (!encrytStr) {
        return ;
    }
    
    LRWeakSelf(self);
    id result=message;
    if ([message isKindOfClass:[NSData class]]&&message) {
        result=[NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingMutableContainers error:nil];
        NSMutableDictionary *containDic=[NSMutableDictionary dictionaryWithDictionary:result];
        
        NSArray *payArr=[result objectForKey:@"payload"];
//
//
//        //判断socket类型
//        NSDictionary *payloadContent =[payArr firstObject];
//        NSString *socketType=[payloadContent objectForKey:@"type"];
//        if (![socketType containsString:@"conversation.otr-message-add"]) {
//            [weakself.delegate SocketDidReceiveMessage:containDic];
//            return;
//        }
        
        if (payArr.count>0) {
            NSMutableArray *payloadArr=[[NSMutableArray alloc] init];
            NSDictionary *item=[payArr firstObject];
            NSString *text =[[item objectForKey:@"data"] objectForKey:@"text"];
            
            NSLog(@"text============%@",text);
            if (text==nil||!text) {
                text=@"";
            }
            NSData *data=[[NSData alloc] initWithBase64EncodedString:text options:0];
            unsigned char const *cd=data.bytes;
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *enableUser=[NSMutableDictionary dictionaryWithDictionary:item];
            NSMutableDictionary *mutabData=[[NSMutableDictionary alloc] initWithDictionary:[item objectForKey:@"data"]];
            [mutabData setObject:encrytStr forKey:@"text"];
            
            [enableUser setObject:mutabData forKey:@"data"];
            
            
            if ([[item allKeys] containsObject:@"from"]) {
   
                
                NSString *userId=[item objectForKey:@"from"];
                [self getUserInfoById:userId complete:^(id responseObj) {
                    NSString *handle=[responseObj objectForKey:@"handle"];
                    [enableUser setObject:handle forKey:@"fromHandle"];
                    
                    [payloadArr addObject:enableUser];
                    //                        NSLog(@"weak.payloadArr=======%@",weakself.payloadArr);
                    
                    [containDic setObject:payloadArr forKey:@"payload"];
                    NSLog(@"************************** socket收到消息啦************************** ");
                    
                    NSString *clientid = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
                    
                    NSString *currentClientId=   [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
                    NSDictionary *payload=  [[containDic objectForKey:@"payload"] firstObject];
                    NSString *recClientId=[[payload objectForKey:@"data"] objectForKey:@"recipient"];
                    NSString *alertContent= [[payload objectForKey:@"data"] objectForKey:@"text"];
                    
                    [weakself.delegate SocketDidReceiveMessage:containDic];
                    if ([recClientId isEqualToString:currentClientId]) {
                    
                        [self locationPushByContent:alertContent];
                    
                    }
                } fail:^(id error) {
                    
                    [weakself.delegate SocketDidReceiveMessage:error];
                }];
                
                
            }
            
        }
        
    }
}


@end
