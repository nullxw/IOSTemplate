//
//  RequestCenter.m
//  ShadowFiend
//
//  Created by tixa on 14-8-14.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "RequestCenter.h"

#define DEFAULT_TIMEOUT 30.0             // 普通json请求超时时间30秒
#define UPDOWN_DEFAULT_TIMEOUT 300.0     // 上传下载网络请求超时时间300秒

@interface RequestCenter ()
{
    AFHTTPRequestOperationManager     *_operationManager;
}

@end


@implementation RequestCenter

static RequestCenter *defaultCenterInstance = nil;

+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultCenterInstance = [[self alloc] init];
        });
    }
    return defaultCenterInstance;
}

- (instancetype)init
{
    self = [super init];
	if (self) {
        
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
	}
	return self;
}

// 基本请求
- (void)postRequestPath:(NSString *)path
          requestMethod:(RequestMethod)requestMethod
         requestHeaders:(NSMutableDictionary *)requestHeaders
             parameters:(NSDictionary *)parameters
                 finish:(FinishBlock)finish
                failure:(FailureBlock)failure
{
    [_operationManager.requestSerializer setTimeoutInterval:DEFAULT_TIMEOUT];
    _operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/gif",@"image/png", nil];
    for (NSString *key in [requestHeaders allKeys]) {
        NSString *value = [requestHeaders objectForKey:key];
        [_operationManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    if (requestMethod == RequestMethodGet) {
        [_operationManager GET:path parameters:parameters success:finish failure:failure];
    }else if (requestMethod == RequestMethodPost){
        [_operationManager POST:path parameters:parameters success:finish failure:failure];
    }else if (requestMethod == RequestMethodPUT){
        [_operationManager PUT:path parameters:parameters success:finish failure:failure];
    }else if (requestMethod == RequestMethodPATCH){
        [_operationManager PATCH:path parameters:parameters success:finish failure:failure];
    }else if (requestMethod == RequestMethodDELETE){
        [_operationManager DELETE:path parameters:parameters success:finish failure:failure];
    }else if (requestMethod == RequestMethodHEAD){
        [_operationManager HEAD:path parameters:parameters success:^(AFHTTPRequestOperation *operation) {
            if (finish) {
                finish(operation,nil);
            }
        } failure:failure];
    }
    
}

// 基础上传::上传请求 fileLength 单位:M
- (void)postUploadPath:(NSString *)path
            parameters:(NSDictionary *)parameters
        requestHeaders:(NSMutableDictionary *)requestHeaders
                  body:(BodyBlock)bodyBlock
                finish:(FinishBlock)finish
               failure:(FailureBlock)failure
{
    _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/gif",@"image/png", nil];
    [_operationManager.requestSerializer setTimeoutInterval:UPDOWN_DEFAULT_TIMEOUT];
    for (NSString *key in [requestHeaders allKeys]) {
        NSString *value = [requestHeaders objectForKey:key];
        [_operationManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    [_operationManager POST:path parameters:parameters constructingBodyWithBlock:bodyBlock success:finish failure:failure];
}

// 基础上传::上传请求 fileLength 单位:M  带有进度提示
- (void)postUploadPath:(NSString *)path
            parameters:(NSDictionary *)parameters
        requestHeaders:(NSMutableDictionary *)requestHeaders
                  body:(BodyBlock)bodyBlock
               process:(void (^)(float fileLength, float progress))process
                finish:(FinishBlock)finish
               failure:(FailureBlock)failure
{
    _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/gif",@"image/png", nil];
    [_operationManager.requestSerializer setTimeoutInterval:UPDOWN_DEFAULT_TIMEOUT];
    for (NSString *key in [requestHeaders allKeys]) {
        NSString *value = [requestHeaders objectForKey:key];
        [_operationManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    AFHTTPRequestOperation *operation = [_operationManager POST:path parameters:parameters constructingBodyWithBlock:bodyBlock success:finish failure:failure];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"%d      %lld      %lld",bytesWritten , totalBytesWritten, totalBytesExpectedToWrite);
        if (process) {
            
            float filelen = 0.0;
            float pro = 0.0;
            if (totalBytesExpectedToWrite <= 0) {
                filelen = 0.0;
                pro = -1.0;
            }else{
                filelen = totalBytesExpectedToWrite/1024.0/1024.0;
                pro = totalBytesWritten/(totalBytesExpectedToWrite*1.0);
            }
            process(filelen, pro);
        }
    }];
    
}

/// 基础下载::下载请求 fileLength 单位:M  不带进度
- (void)postDownloadPath:(NSString *)path
              parameters:(NSDictionary *)parameters
          requestHeaders:(NSMutableDictionary *)requestHeaders
                  finish:(FinishBlock)finish
                 failure:(FailureBlock)failure
{
    _operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/gif",@"image/png", nil];
    for (NSString *key in [requestHeaders allKeys]) {
        NSString *value = [requestHeaders objectForKey:key];
        [_operationManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [_operationManager.requestSerializer setTimeoutInterval:UPDOWN_DEFAULT_TIMEOUT];
    [_operationManager POST:path parameters:parameters success:finish failure:failure];
    
}

/// 基础下载::下载请求 fileLength 单位:M  带进度
- (void)postDownloadPath:(NSString *)path
              parameters:(NSDictionary *)parameters
          requestHeaders:(NSMutableDictionary *)requestHeaders
                 process:(void (^)(float fileLength, float progress))process
                  finish:(FinishBlock)finish
                 failure:(FailureBlock)failure
{
    _operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/gif",@"image/png", nil];
    for (NSString *key in [requestHeaders allKeys]) {
        NSString *value = [requestHeaders objectForKey:key];
        [_operationManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [_operationManager.requestSerializer setTimeoutInterval:UPDOWN_DEFAULT_TIMEOUT];
    AFHTTPRequestOperation *operation = [_operationManager POST:path parameters:parameters success:finish failure:failure];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (process) {
            //            NSLog(@"%d      %lld      %lld",bytesRead, totalBytesRead, totalBytesExpectedToRead);
            float filelen = 0.0;
            float pro = 0.0;
            if (totalBytesExpectedToRead <= 0) {
                filelen = 0.0;
                pro = -1.0;
            }else{
                filelen = totalBytesExpectedToRead/1024.0/1024.0;
                pro = totalBytesRead/(totalBytesExpectedToRead*1.0);
            }
            process(filelen,pro);
        }
    }];
    
}

// 扩展下载::文件下载支持断点续传
- (void)postExtendDownloadResumePath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                      requestHeaders:(NSMutableDictionary *)requestHeaders
                     destinationPath:(NSString *)destinationPath
                             process:(void (^)(float fileLength, float progress))process
                              finish:(FinishBlock)finish
                             failure:(FailureBlock)failure
{
    _operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"image/gif",@"image/png", nil];
    for (NSString *key in [requestHeaders allKeys]) {
        NSString *value = [requestHeaders objectForKey:key];
        [_operationManager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    NSMutableURLRequest *request = [_operationManager.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
    [request setTimeoutInterval:UPDOWN_DEFAULT_TIMEOUT];
    // 检查文件是否已经下载了一部分
    unsigned long long downloadedBytes = [self fileSizeForPath:destinationPath];
    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"%llu",downloadedBytes];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    // 不使用缓存,避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    // 下载请求
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    // 下载路径
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:destinationPath append:YES];
    // 下载进度回调
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        NSLog(@"%d      %lld      %lld",bytesRead, totalBytesRead, totalBytesExpectedToRead);
        
        if (process) {
            float filelen = 0.0;
            float pro = 0.0;
            if ((totalBytesExpectedToRead + downloadedBytes) <= 0) {
                filelen = 0.0;
                pro = -1.0;
            }else{
                filelen = (totalBytesExpectedToRead + downloadedBytes)/1024.0/1024.0;
                pro = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
            }
            process(filelen,pro);
        }
    }];
    [operation setCompletionBlockWithSuccess:finish failure:failure];
    [operation start];
    
}

- (unsigned long long)fileSizeForPath:(NSString *)path
{
    unsigned long long fileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

@end
