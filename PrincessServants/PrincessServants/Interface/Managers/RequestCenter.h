//
//  RequestCenter.h
//  ShadowFiend
//
//  Created by tixa on 14-8-14.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"
//#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

typedef enum {
    RequestMethodGet     = 0,    // GET
    RequestMethodPost    = 1,    // POST
    RequestMethodPUT     = 2,    // PUT
    RequestMethodPATCH   = 3,    // PATCH
    RequestMethodDELETE  = 4,    // DELETE
    RequestMethodHEAD    = 5,    // HEAD
    RequestMethodOther   = 6
} RequestMethod;

#if NS_BLOCKS_AVAILABLE

typedef void (^FinishBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^FailureBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void (^BodyBlock)(id <AFMultipartFormData> formData);

#endif

@interface RequestCenter : SFObject

+ (instancetype)defaultCenter;

// 基本请求
- (void)postRequestPath:(NSString *)path
          requestMethod:(RequestMethod)requestMethod
         requestHeaders:(NSMutableDictionary *)requestHeaders
             parameters:(NSDictionary *)parameters
                 finish:(FinishBlock)finish
                failure:(FailureBlock)failure;


// 基础上传::上传请求   不带进度提示AFNetworing默认实现的
- (void)postUploadPath:(NSString *)path
            parameters:(NSDictionary *)parameters
        requestHeaders:(NSMutableDictionary *)requestHeaders
                  body:(BodyBlock)bodyBlock
                finish:(FinishBlock)finish
               failure:(FailureBlock)failure;


/// 基础上传::上传请求 fileLength 单位:M  带有进度提示
- (void)postUploadPath:(NSString *)path
            parameters:(NSDictionary *)parameters
        requestHeaders:(NSMutableDictionary *)requestHeaders
                  body:(BodyBlock)bodyBlock
               process:(void (^)(float fileLength, float progress))process
                finish:(FinishBlock)finish
               failure:(FailureBlock)failure;

/// 基础下载::下载请求    不带进度
- (void)postDownloadPath:(NSString *)path
              parameters:(NSDictionary *)parameters
          requestHeaders:(NSMutableDictionary *)requestHeaders
                  finish:(FinishBlock)finish
                 failure:(FailureBlock)failure;

/// 基础下载::下载请求 fileLength 单位:M  带进度
- (void)postDownloadPath:(NSString *)path
              parameters:(NSDictionary *)parameters
          requestHeaders:(NSMutableDictionary *)requestHeaders
                 process:(void (^)(float fileLength, float progress))process
                  finish:(FinishBlock)finish
                 failure:(FailureBlock)failure;


// 扩展下载::文件下载支持断点续传
- (void)postExtendDownloadResumePath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                      requestHeaders:(NSMutableDictionary *)requestHeaders
                     destinationPath:(NSString *)destinationPath
                             process:(void (^)(float fileLength, float progress))process
                              finish:(FinishBlock)finish
                             failure:(FailureBlock)failure;

@end
