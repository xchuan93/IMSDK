//
//  IMKXGroupModel.m
//  IMSDKProject
//
//  Created by Apple on 2018/7/2.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "IMKXGroupModel.h"

@implementation IMKXGroupModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"selfModel" : @"members.self",
             @"otherModel" : @"members.others",
             @"groupId" : @"id",
             @"memberModel" :@"members"
             };
}

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"groupId":@"id"}];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation MemberModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"selfModel":@"self",@"otherModel":@"others"}];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation XCMemberSelfModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"memberId" : @"id"};
}

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"memberId":@"id"}];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation XCMemberOthersModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"otherId" : @"id"};
}

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{@"otherId":@"id"}];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
