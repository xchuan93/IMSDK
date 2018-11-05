//
//  IMKXSocketRocketUtility.h
//  SUN
//
//  Created by  on 18/7/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketRocket.h"

extern NSString * const kNeedPayOrderNote;
extern NSString * const kWebSocketDidOpenNote;
extern NSString * const kWebSocketDidCloseNote;
extern NSString * const kWebSocketdidReceiveMessageNote;

@interface IMKXSocketRocketUtility : NSObject
 // 获取连接状态
@property (nonatomic,assign,readonly) SRReadyState socketReadyState;

+ (IMKXSocketRocketUtility *)instance;

-(void)SRWebSocketOpenWithURLString:(NSString *)urlString;//开启连接
-(void)SRWebSocketClose;//关闭连接
- (void)sendData:(id)data;//发送数据

@end
