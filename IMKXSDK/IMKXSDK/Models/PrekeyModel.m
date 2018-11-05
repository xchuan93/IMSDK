//
//  PrekeyModel.m
//  IMKXSDK
//
//  Created by Apple on 2018/7/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "PrekeyModel.h"

@implementation ClientPrekeyModel

@end

@implementation PrekeyModel

+(BOOL)propertyIsOptional:(NSString *)propertyName{
    
    
    return YES;
}



+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"clientId":@"id"}];
}

@end
