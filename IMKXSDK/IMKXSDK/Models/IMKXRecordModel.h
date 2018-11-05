//
//  IMKXRecordModel.h
//  IMSDKProject
//
//  Created by Apple on 2018/6/22.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMKXRecordModel : NSObject
@property (nonatomic,strong)NSString *msgTime;
@property (nonatomic,strong)NSString *msgText;
@property (nonatomic,strong)NSData *msgData;
@property (nonatomic,strong)NSString *sendID;
@property (nonatomic,strong)NSString *receiveID;
@property (nonatomic,strong)NSString *sendHead;
@property (nonatomic,strong)NSString *receiveHead;
@property (nonatomic,strong)NSString *sendName;
@property (nonatomic,strong)NSString *receiveName;
@end
