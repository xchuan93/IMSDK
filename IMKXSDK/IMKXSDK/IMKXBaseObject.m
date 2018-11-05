//
//  IMBaseObject.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXBaseObject.h"
#import "IMKXAFNetTool.h"
@implementation IMKXBaseObject

-(void)debugMsg:(NSString *)cnvid complete:(void(^)(id responseObj))success fail:(void(^)(id error))fail{
    
    NSLog(@"debugMsg==============");
    
    NSString *url=[@"https://web3.imkexin.com/conversations/" stringByAppendingString:cnvid];
    [[IMKXAFNetTool shared] post:url parameters:@{} httpMethod:@"get" progress:^(NSProgress *uploadProgress) {
        
    } success:^(id responseObj) {
        
        success(responseObj);
        
    } failure:^(id error) {
        fail(error);
    }];
    
}




@end
