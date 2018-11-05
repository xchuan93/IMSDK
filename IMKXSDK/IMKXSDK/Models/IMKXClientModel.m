//
//  IMKXClientModel.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/5.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXClientModel.h"

@implementation IMKXClientModel

+(JSONKeyMapper *)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:
            @{
              @"clientId":@"id",
              @"clientClass":@"class"
              }
            ];
}
+(BOOL)propertyIsOptional:(NSString *)propertyName{
    return YES;
}


@end
