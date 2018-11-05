//
//  IMKXClientModel.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/5.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
@interface IMKXClientModel : JSONModel
@property (nonatomic,strong)NSString *time;
@property (nonatomic,strong)NSString *clientId;
@property(nonatomic,strong)NSString *model;
@property(nonatomic,strong)NSString *clientClass;
@property(nonatomic,strong)NSString *label;
@property(nonatomic,strong)NSString *type;

@end
