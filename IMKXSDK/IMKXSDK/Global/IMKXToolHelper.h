//
//  IMKXToolHelper.h
//  IMSDKProject
//
//  Created by Apple on 2018/7/9.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

#define KgetSize(view) view.frame.size

#define KClientKey @"clientIdenKey"

#define KCurrentClientKey @"currentClientKey"


#define KCurrentLoginToken @"currentLoginToken"

#define KLastNotiKey @"lastNotiKey"
//获取通知中心
#define LRNotificationCenter [NSNotificationCenter defaultCenter]
//设置随机颜色
#define LRRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
//设置RGB颜色/设置RGBA颜色
#define LRRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define LRRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(r)/255.0 alpha:a]
// clear背景颜色
#define LRClearColor [UIColor clearColor]

#ifdef DEBUG
#define LRLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define LRLog(...)

#endif
//6.弱引用/强引用
#define LRWeakSelf(type)  __weak typeof(type) weak##type = type;
#define LRStrongSelf(type)  __strong typeof(type) type = weak##type;

//获取图片资源
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]

#define LRCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])
//使用 ARC 和 MRC
#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif
//判断当前的iPhone设备/系统版本
//判断是否为iPhone
//#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])

//判断是否为iPad
//#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPAD ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"])

//判断是否为ipod
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

// 判断是否为 iPhone 5SE
#define iPhone5SE [[UIScreen mainScreen] bounds].size.width == 320.0f && [[UIScreen mainScreen] bounds].size.height == 568.0f

// 判断是否为iPhone 6/6s
#define iPhone6_6s [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 667.0f

// 判断是否为iPhone 6Plus/6sPlus
#define iPhone6Plus_6sPlus [[UIScreen mainScreen] bounds].size.width == 414.0f && [[UIScreen mainScreen] bounds].size.height == 736.0f

//获取系统版本
//这个方法不是特别靠谱
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
//建议使用这个方法
#define IOS_SYSTEM_STRING [[UIDevice currentDevice] systemVersion]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif
//获取temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);

//设备信息
//设备相关信息的获取
#define KDeviceName [[UIDevice currentDevice] name]

#define KDeviceSystemName  [[UIDevice currentDevice] systemName];

#define KDeviceSystemVersion [[UIDevice currentDevice] systemVersion];

#define KDeviceModel [[UIDevice currentDevice] model];

#define KDeviceLocal  [[UIDevice currentDevice] localizedModel];  // localized version of model
//沙盒
#define KSetIMKXUser(value,key)\
[[NSUserDefaults standardUserDefaults]setObject:value forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];



#define KGetIMKXUser(param)\
  [[NSUserDefaults standardUserDefaults] objectForKey:param];

@interface IMKXToolHelper : NSObject
+ (NSString*)deviceModelName;

+(NSString *)getFileMD5String:(NSData *)data;

@end
