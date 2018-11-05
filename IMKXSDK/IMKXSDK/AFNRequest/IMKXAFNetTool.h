//
//  IMKXAFNetTool.h
//  MaintenancePlat
//
//  Created by sunnet on 2017/12/18.
//  Copyright © 2017年 sunnet. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef void(^SuccessBlock)(NSURLSessionDataTask * task , id  responseBody);
typedef void(^FailureBlock)(NSURLSessionDataTask * task , NSError * error);
typedef void(^ProgressBlock)(NSProgress * downloadProgress);

@interface IMKXAFNetTool : NSObject

+(IMKXAFNetTool *)shared;
#pragma mark 数据请求
-(void)post:(NSString *)url parameters:(NSDictionary *)params httpMethod:(NSString *)method progress:(void(^)(NSProgress *uploadProgress))progress success:(void (^)(id responseObj))success failure:(void (^)(id error))failure;

#pragma mark upLoad上传
//-(void)upLoadFileWithModel:(UploadParam *)uploadModel Parameter:(NSDictionary *)parameter Url:(NSString *)urlStr  Progress:(ProgressBlock)progressBlock
//              successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

@end
