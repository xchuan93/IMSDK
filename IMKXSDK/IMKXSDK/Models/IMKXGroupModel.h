//
//  IMKXGroupModel.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/2.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import <JSONModel/JSONModel.h>
@protocol XCMemberSelfModel
@end
@interface XCMemberSelfModel : JSONModel
@property (nonatomic, copy) NSString <Optional> *hidden_ref;
@property (nonatomic, copy) NSString <Optional> *status;
@property (nonatomic, copy) NSString <Optional> *service;
@property (nonatomic, copy) NSString <Optional> *otr_muted_ref;
@property (nonatomic, copy) NSString <Optional> *status_time;
@property (nonatomic, copy) NSString <Optional> *hidden;
@property (nonatomic, copy) NSString <Optional> *status_ref;
@property (nonatomic, copy) NSString <Optional> *memberId;
@property (nonatomic, copy) NSString <Optional> *otr_archived;
@property (nonatomic, copy) NSString <Optional> *otr_muted;
@property (nonatomic, copy) NSString <Optional> *otr_archived_ref;
@end


@protocol XCMemberOthersModel
@end
@interface XCMemberOthersModel : JSONModel
@property (nonatomic, copy) NSString <Optional> *status;
@property (nonatomic, copy) NSString <Optional> *otherId;
@end

@protocol MemberModel
@end
@interface MemberModel : JSONModel

@property (nonatomic, copy) XCMemberSelfModel<Optional> *selfModel;
@property (nonatomic, copy) NSArray <Optional,XCMemberOthersModel> * otherModel;

@end

@protocol IMKXGroupModel
@end
@interface IMKXGroupModel : JSONModel
@property (nonatomic, copy) NSArray <Optional> *access;
@property (nonatomic, copy) NSString <Optional> *creator;
@property (nonatomic, copy) NSString <Optional> *access_role;
@property (nonatomic, copy) NSString <Optional> *name;
@property (nonatomic, copy) NSString <Optional> *team;
@property (nonatomic, copy) NSString <Optional> *groupId;
@property (nonatomic, copy) NSString <Optional> *type;
@property (nonatomic, copy) NSString <Optional> *last_event_time;
@property (nonatomic, copy) NSString <Optional> *last_event;
@property (nonatomic, copy) MemberModel<Optional> *members;
@end

