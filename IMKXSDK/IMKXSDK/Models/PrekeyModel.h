//
//  PrekeyModel.h
//  IMKXSDK
//
//  Created by Apple on 2018/7/20.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol PrekeyModel
@end
@interface PrekeyModel : JSONModel

@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *key;

@end


@protocol ClientPrekeyModel
@end
@interface ClientPrekeyModel : JSONModel

//@property (nonatomic,strong)NSString *userId;
@property (nonatomic, copy) NSString *client;
@property (nonatomic, copy) PrekeyModel <Optional> *prekey;

@end
