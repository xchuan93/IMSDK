 //
//  IMKXAFNetTool.m
//  MaintenancePlat
//
//  Created by sunnet on 2017/12/18.
//  Copyright © 2017年 sunnet. All rights reserved.
//

#import "IMKXAFNetTool.h"
#import "IMKXConstObject.h"
#import "IMKXToolHelper.h"
#import  <AFNetworking/AFNetworking.h>
static NSString *preUrl=@"";
static NSString *cookie;

@interface IMKXAFNetTool()

@property (nonatomic,strong) AFHTTPSessionManager *manager;
@end

@implementation IMKXAFNetTool
+(IMKXAFNetTool *)shared{
    static IMKXAFNetTool *tool=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool=[[IMKXAFNetTool alloc] init];
    });
    return tool;
}
-(AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager=[AFHTTPSessionManager manager];
        _manager.requestSerializer =[AFJSONRequestSerializer serializer];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_manager.requestSerializer setTimeoutInterval:12];
 
    }
    return _manager;
}
-(void)post:(NSString *)url parameters:(NSDictionary *)params httpMethod:(NSString *)method progress:(void(^)(NSProgress *uploadProgress))progress success:(void (^)(id responseObj))success failure:(void (^)(id error))failure{
    NSLog(@"%@=========%@\n param==========%@\n method=========%@",method,url,params,method);
    //post
    if ([[method lowercaseString] isEqualToString:@"post"]) {
        [ self.manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            progress(uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"response===========%@",responseObject);
            
            if ([url containsString:@"login/sdk?persist=true"]) {
                if ([self configTokenHead:responseObject]) {
                    success(responseObject);
                }
            }
            
            else if([url containsString:@"assets/v3"]){
                
                
            }
            
            else {
                success(responseObject);
            }
       
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 
            [self dealFailCallBack:task failure:error failCallBack:failure];
        }];
    }
    
    //get
    else if ([[method lowercaseString] isEqualToString:@"get"]){
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain", nil];
      
        [self.manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            progress(downloadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"response===========%@",responseObject);
            success(responseObject);
          
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self dealFailCallBack:task failure:error failCallBack:failure];
        }];
    }
    //put
    else if ([[method lowercaseString] isEqualToString:@"put"]){
        [self.manager PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSLog(@"response===========%@",responseObject);
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               [self dealFailCallBack:task failure:error failCallBack:failure];
        }];
    }
 
    //Delete
    else if([[method lowercaseString] isEqualToString:@"delete"]){
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/javascript",@"text/json",@"text/plain", nil];
        self.manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        [self.manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"response===========%@",responseObject);
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self dealFailCallBack:task failure:error failCallBack:failure];
        }];
    }
}


-(void)configFileHead{
    [self.manager.requestSerializer setValue:@"multipart/mixed;boundary=frontier" forHTTPHeaderField:@"Content-Type"];
    [self.manager.requestSerializer setValue:@"multipart/mixed;boundary=frontier" forHTTPHeaderField:@"Content-Type"];
   
}


-(BOOL)configTokenHead:(id)response{
    NSString *token =[response objectForKey:@"access_token"];
    if (!token||(!(token.length>0))) {
        token = KGetIMKXUser(KCurrentLoginToken);
    }
    [self.manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    NSHTTPCookieStorage * cookieJar=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *tempCookie in [cookieJar cookies]) {
        NSLog(@"getCookie:%@",tempCookie);
        cookie=tempCookie.value;
        [IMKXConstObject shared].constCookie=cookie;
    }
//   [self.manager.requestSerializer setValue:cookie forKey:@"zuid"];
    [self.manager.requestSerializer  setValue:[IMKXConstObject shared].constCookie forHTTPHeaderField:@"zuid"];
    return YES;
 
}


-(void)dealFailCallBack:(NSURLSessionDataTask *)task failure:(NSError *)error failCallBack:(void (^)(id error))callBack{
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
     NSInteger statuCode=responses.statusCode;
    
    NSLog(@"statusCode=======%ld",statuCode);
    
    NSDictionary *errinfo= error.userInfo;
    if (errinfo==nil) {
        callBack([@"IM Server Error." stringByAppendingFormat:@"%ld",statuCode]);
        return;
    }
 
    NSData* errorUserData=  [errinfo objectForKey:@"com.alamofire.serialization.response.error.data"];
    if (!errorUserData||errorUserData==nil) {
        NSString *tokenA =KGetIMKXUser(KCurrentLoginToken);
        callBack([@"IM ErrorData Error. " stringByAppendingFormat:@"%ld %@",statuCode,tokenA]);
        return;
    }
    
    NSString *erroMessage=@"IM Error";
    id errorDic= [NSJSONSerialization JSONObjectWithData:errorUserData options:NSJSONReadingMutableContainers error:nil];
 
    NSLog(@"errorDic=======%@",errorDic);
    
    if ([errorDic isKindOfClass:[NSDictionary class]]) {
        erroMessage = [errorDic objectForKey:@"message"];
        NSLog(@"IM Server Error======%@",erroMessage);
    }
    callBack(erroMessage);
}


//获取cookie
-(void)dealCookie{
    NSHTTPCookieStorage * cookieJar=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *tempCookie in [cookieJar cookies]) {
        NSLog(@"getCookie:%@",tempCookie);
        cookie=tempCookie.value;
        [IMKXConstObject shared].constCookie=cookie;
    }
}

 
@end
