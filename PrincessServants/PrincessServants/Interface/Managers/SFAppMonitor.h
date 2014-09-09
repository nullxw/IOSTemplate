//
//  SFAppMonitor.h
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"
#import <CoreLocation/CLLocation.h>

typedef enum {
    CellularProviderUnknown,        //未知
    CellularProviderChinaMobile,    //中国移动
    CellularProviderChinaUnicom,    //中国联通
    CellularProviderChinaTelecom,   //中国电信
    CellularProviderChinaTietong    //中国铁通
} CellularProvider;

@interface SFAppMonitor : SFObject

// 启用错误日志收集，默认为YES
@property (nonatomic) BOOL      enableErrorLog;
// 启用位置日志收集，默认为YES
@property (nonatomic) BOOL      enableLocationLog;

// 日志发送间隔。每次APP启动或切换到指定网络环境时检测,超过此间隔时发送日志。单位小时,最小为1,默认为24。
@property (nonatomic) NSInteger logSendInterval;
// 仅在wifi环境下发送日志，默认为YES
@property (nonatomic) BOOL      logSendWifiOnly;

+ (instancetype)sharedMonitor;

// 手动记录设备及APP信息并持久化
- (void)logAppInfo;

// 手动记录位置信息并持久化
- (void)logLocationWithCoordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address;

// 手动标记事件开始     只是标记开始并未持久化
- (void)logEventStartWithModuleName:(NSString *)moduleName eventName:(NSString *)eventName;
// 手动标记事件结束并且持久化   该方法应该在开始方法调用之后某一时刻调用
- (void)logEventEndWithModuleName:(NSString *)moduleName eventName:(NSString *)eventName;
// 手动记录事件,此事件只有发生时间,并持久化
- (void)logEventWithModuleName:(NSString *)moduleName eventName:(NSString *)eventName;

// 手动记录错误日志并进行持久化
- (void)logError:(NSString *)error;
// 检测是否应该发送日志文件
- (void)checkLogs;


// 设备UDID    删除应用后重装ID不变
- (NSString *)deviceUDID;
// 设备类型
- (NSString *)deviceModel;
// 系统名
- (NSString *)deviceSystemName;
// 系统版本
- (NSString *)deviceSystemVersion;
// 系统版本数值
- (CGFloat)deviceSystemVersionValue;
// 是否已越狱
- (BOOL)isJailBroken;
// 是否为iPad
- (BOOL)isIPad;


// 程序名
- (NSString *)appName;
// 程序 bundleIdentifier
- (NSString *)appID;
// 程序首个scheme
- (NSString *)appScheme;
// 程序版本
- (NSString *)appVersion;
// 程序版本数值
- (CGFloat)appVersionValue;


// 当前IP地址
- (NSString *)IPAddress;
// 获取运营商
- (CellularProvider)cellularProvider;
// 获取运营商名称
- (NSString *)cellularProviderName;
// 是否已连入互联网
- (BOOL)isReachable;
// 是否已连入蜂窝网络
- (BOOL)isReachableViaWWAN;
// 是否已连入WiFi
- (BOOL)isReachableViaWiFi;
// 获取网络环境
- (NSString *)networkStatus;

@end
