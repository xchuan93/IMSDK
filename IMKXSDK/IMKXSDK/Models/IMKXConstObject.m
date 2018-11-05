//
//  IMKXConstObject.m
//  SecretSDKProject
//
//  Created by Apple on 2018/6/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXConstObject.h"

@implementation IMKXConstObject
+(IMKXConstObject *)shared{
    static IMKXConstObject *tool=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool=[[IMKXConstObject alloc] init];
    });
    return tool;
}

- (void)setConstToken:(NSString *)constToken{
        _constToken=constToken;
}


-(NSMutableArray *)clientDeviceArr{
    
    if(!_clientDeviceArr){
        _clientDeviceArr=[[NSMutableArray alloc] init];
    }
    return _clientDeviceArr;
}


-(void)uploadAsset:(NSData *)fileData;{
    
     
    
    
    
}


//+ (NSString *)descriptionWithLocale:(id)locale
//{
//    NSString *string;
//    @try {
//        string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:locale options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
//    } @catch (NSException *exception) {
//        NSString *reason = [NSString stringWithFormat:@"reason:%@",exception.reason];
//        string = [NSString stringWithFormat:@"转换失败:/n%@,/n转换终止,输出如下:/n%@",reason,self.description];
//    } @finally {
//    }
//    return string;
//}
@end
