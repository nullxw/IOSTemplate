//
//  SFAppMonitor.m
//  ShadowFiend
//
//  Created by tixa on 14-6-26.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFAppMonitor.h"
#import "SFFileManager.h"
#import "sys/utsname.h"
#include <netdb.h>
#include <arpa/inet.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "AFNetworkReachabilityManager.h"
#import "AccountCenter.h"

#define kLastSendLogAppInfo     @"AM_LastSendLog_AppInfo"
#define kLastSendLogLocation    @"AM_LastSendLog_Location"
#define kLastSendLogEvent       @"AM_LastSendLog_Event"
#define kLastSendLogError       @"AM_LastSendLog_Error"

#define kLogFilePathAppInfo     @"AppMonitor/AppInfoLog"
#define kLogFilePathLocation    @"AppMonitor/LocationLog"
#define kLogFilePathEvent       @"AppMonitor/EventLog"
#define kLogFilePathError       @"AppMonitor/ErrorLog"

@interface SFAppMonitor ()
{
    NSMutableDictionary *_eventLoggingDictionary;   // 事件信息暂存字典  用来暂存事件开始,当事件结束触发则转存_eventLogsArray并持久化
    
    NSMutableArray *_appInfoLogsArray;       // 应用信息
    NSMutableArray *_locationLogsArray;      // 位置信息
    NSMutableArray *_eventLogsArray;         // 事件信息
    NSMutableArray *_errorLogsArray;         // 错误信息
}
@end

@implementation SFAppMonitor

static SFAppMonitor *sharedMonitorInstance = nil;

- (instancetype)init
{
    self = [super init];
	if (self) {
        _eventLoggingDictionary = [[NSMutableDictionary alloc] init];
        _appInfoLogsArray       = [SFFileManager loadArray:kLogFilePathAppInfo];
        _locationLogsArray      = [SFFileManager loadArray:kLogFilePathLocation];
        _eventLogsArray         = [SFFileManager loadArray:kLogFilePathEvent];
        _errorLogsArray         = [SFFileManager loadArray:kLogFilePathError];
        
        self.logSendWifiOnly    = YES;
        self.logSendInterval    = 24;
        
        self.enableErrorLog     = YES;
        self.enableLocationLog  = YES;
        
        //检测并发送日志
        [self checkLogs];
	}
	return self;
}

+ (instancetype)sharedMonitor;
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            sharedMonitorInstance = [[self alloc] init];
        });
    }
    return sharedMonitorInstance;
}



#pragma mark - Property

- (void)setLogSendInterval:(NSInteger)logSendInterval
{
    _logSendInterval = MAX(logSendInterval, 1);
}

- (void)setEnableErrorLog:(BOOL)enableErrorLog
{
    _enableErrorLog = enableErrorLog;
    if (enableErrorLog) {
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    } else {
        NSSetUncaughtExceptionHandler(nil);
    }
}

- (void)setEnableLocationLog:(BOOL)enableLocationLog
{
    _enableLocationLog = enableLocationLog;
//    if (enableLocationLog) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(receiveAddressDidUpdateNotification:)
//                                                     name:LCUserAddressDidUpdateNotification
//                                                   object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(receiveGeocodeDidFailNotification:)
//                                                     name:LCGeocodeDidFailNotification
//                                                   object:nil];
//    } else {
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:LCUserAddressDidUpdateNotification
//                                                      object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:LCGeocodeDidFailNotification
//                                                      object:nil];
//    }
}



#pragma mark - Info Log

// 手动记录APP信息并持久化
- (void)logAppInfo
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *resolution = [NSString stringWithFormat:@"%.fx%.f", screenBounds.size.width, screenBounds.size.height];
    
    NSString *channel = @"内测";
    
    NSNumber *milliseconds = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSMutableDictionary *appInfo = [[NSMutableDictionary alloc] init];
    [appInfo setValue:self.deviceModel          forKey:@"mm"];
    [appInfo setValue:resolution                forKey:@"mr"];
    [appInfo setValue:@"苹果"                    forKey:@"mb"];
    [appInfo setValue:self.deviceSystemName     forKey:@"ot"];
    [appInfo setValue:self.deviceSystemVersion  forKey:@"om"];
    [appInfo setValue:self.appName              forKey:@"cn"];
    [appInfo setValue:self.appVersion           forKey:@"cm"];
    [appInfo setValue:channel                   forKey:@"ca"];
    [appInfo setValue:self.cellularProviderName forKey:@"no"];
    [appInfo setValue:milliseconds              forKey:@"m"];
    [appInfo setValue:milliseconds              forKey:@"c"];
    [_appInfoLogsArray addObject:appInfo];
    
    [SFFileManager saveObject:_appInfoLogsArray filePath:kLogFilePathAppInfo];
}



#pragma mark - Location Log

- (void)receiveAddressDidUpdateNotification:(NSNotification *)notification
{
    if (!_enableLocationLog) {
        return;
    }
    
//    NSString *address = [[LocationCenter defaultCenter] lastUserAddress];
//    CLLocationCoordinate2D coordinate = [[LocationCenter defaultCenter] lastUserCoordinate];
//    [self logLocationWithLatitude:coordinate.latitude longitude:coordinate.longitude address:address];
}

- (void)receiveGeocodeDidFailNotification:(NSNotification *)notification
{
    if (!_enableLocationLog) {
        return;
    }
    
//    CLLocationCoordinate2D coordinate = [[LocationCenter defaultCenter] lastUserCoordinate];
//    [self logLocationWithLatitude:coordinate.latitude longitude:coordinate.longitude address:nil];
}

// 记录位置信息并持久化
- (void)logLocationWithCoordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address
{
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        NSLog(@"SFAppMonitor 无法记录位置信息:无效经纬度,latitude=%f, longitude=%f, address=%@", coordinate.latitude, coordinate.longitude, address);
        return;
    }
    
    NSNumber *milliseconds = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
    [locationInfo setValue:[NSNumber numberWithDouble:coordinate.latitude]  forKey:@"la"];
    [locationInfo setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"ln"];
    [locationInfo setValue:address                              forKey:@"a"];
    [locationInfo setValue:milliseconds                         forKey:@"c"];
    [_locationLogsArray addObject:locationInfo];
    
    [SFFileManager saveObject:_locationLogsArray filePath:kLogFilePathLocation];
}



#pragma mark - Event Log

// 手动标记事件开始,未持久化
- (void)logEventStartWithModuleName:(NSString *)moduleName eventName:(NSString *)eventName
{
    NSString *eventKey = [NSString stringWithFormat:@"%@_%@", moduleName, eventName];
    NSMutableDictionary *event = [[NSMutableDictionary alloc] init];
    [event setValue:moduleName      forKey:@"moduleName"];
    [event setValue:eventName       forKey:@"eventName"];
    [event setValue:[NSDate date]   forKey:@"beginDate"];
    [_eventLoggingDictionary setValue:event forKey:eventKey];
}

// 手动标记事件结束持久化
- (void)logEventEndWithModuleName:(NSString *)moduleName eventName:(NSString *)eventName
{
    NSString *eventKey = [NSString stringWithFormat:@"%@_%@", moduleName, eventName];
    NSMutableDictionary *event = [_eventLoggingDictionary valueForKey:eventKey];
    if (event) {
        [_eventLoggingDictionary removeObjectForKey:eventKey];
        [self logEventWithModuleName:moduleName
                           eventName:eventName
                           beginDate:[event valueForKey:@"beginDate"]
                             endDate:[NSDate date]];
    } else {
        NSLog(@"SFAppMonitor 无法记录事件日志:未标记开始时间,moduleName=%@, eventName=%@", moduleName, eventName);
    }
}

// 手动记录事件,此事件只有发生时间,并持久化
- (void)logEventWithModuleName:(NSString *)moduleName eventName:(NSString *)eventName
{
    [self logEventWithModuleName:moduleName
                       eventName:eventName
                       beginDate:[NSDate date]
                         endDate:nil];
}

// 记录事件日志并持久化
- (void)logEventWithModuleName:(NSString *)moduleName
                     eventName:(NSString *)eventName
                     beginDate:(NSDate *)beginDate
                       endDate:(NSDate *)endDate
{
    if (!moduleName.length || !eventName.length) {
        NSLog(@"SFAppMonitor 无法记录事件日志:moduleName=%@, eventName=%@", moduleName, eventName);
        return;
    }
    
    NSNumber *beginMS = [NSNumber numberWithLongLong:[beginDate timeIntervalSince1970] * 1000];
    NSNumber *endMS = nil;
    NSNumber *durationMS = nil;
    // 因前面调用只有这两种情况,故此并未对beginDate进行讨论
    if (endDate) { // endDate不为nil的情况
        endMS = [NSNumber numberWithLongLong:[endDate timeIntervalSince1970] * 1000];
        durationMS = [NSNumber numberWithLongLong:endMS.longLongValue - beginMS.longLongValue];
    }else{ // endDate为nil的情况
        endMS = [NSNumber numberWithLongLong:0];
        durationMS = [NSNumber numberWithLongLong:0];
    }
    
    NSMutableDictionary *eventInfo = [[NSMutableDictionary alloc] init];
    [eventInfo setValue:moduleName          forKey:@"mn"];
    [eventInfo setValue:eventName           forKey:@"en"];
    [eventInfo setValue:beginMS             forKey:@"b"];
    [eventInfo setValue:endMS               forKey:@"e"];
    [eventInfo setValue:durationMS          forKey:@"d"];
    [eventInfo setValue:self.networkStatus  forKey:@"n"];
    [_eventLogsArray addObject:eventInfo];
    
    [SFFileManager saveObject:_eventLogsArray filePath:kLogFilePathEvent];
}



#pragma mark - Error Log

// 手动记录错误日志并进行持久化
- (void)logError:(NSString *)error
{
    if (!_enableErrorLog) {
        return;
    }
    
    if (!error.length) {
        NSLog(@"SFAppMonitor 无法记录错误日志:error=%@", error);
        return;
    }
    
    NSNumber *milliseconds = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSString *errorMessage = @"";
    
    NSString *channel = @"内测";
    if (channel.length) {
        errorMessage = [errorMessage stringByAppendingFormat:@"Channel: %@\n", channel];
    }
    
    NSString *deviceModel = self.deviceModel;
    if (deviceModel.length) {
        errorMessage = [errorMessage stringByAppendingFormat:@"Device Model: %@\n", deviceModel];
    }
    
    NSString *systemVersion = self.deviceSystemVersion;
    if (systemVersion.length) {
        errorMessage = [errorMessage stringByAppendingFormat:@"OS Version: %@\n", systemVersion];
    }
    
    NSString *appVersion = self.appVersion;
    if (appVersion.length) {
        errorMessage = [errorMessage stringByAppendingFormat:@"APP Version: %@\n", appVersion];
    }
    
    PSAccount *account = [[AccountCenter defaultCenter] loginAccount];
    if (account) {
        errorMessage = [errorMessage stringByAppendingFormat:@"User ID: %@\n", account.ID];
        errorMessage = [errorMessage stringByAppendingFormat:@"User Name: %@\n", account.name];
    }
    
    errorMessage = [errorMessage stringByAppendingFormat:@"Error:%@\n",error];
    
    NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc] init];
    [errorInfo setValue:errorMessage    forKey:@"e"];
    [errorInfo setValue:appVersion      forKey:@"cm"];
    [errorInfo setValue:self.appName    forKey:@"cn"];
    [errorInfo setValue:milliseconds    forKey:@"c"];
    [_errorLogsArray addObject:errorInfo];
    
    [SFFileManager saveObject:_errorLogsArray filePath:kLogFilePathError];
}

void UncaughtExceptionHandler(NSException *exception)
{
    NSArray *callStackSymbols = [exception callStackSymbols];
    
    NSString *stackMessage = @"";
    for (NSInteger i = 0; i < callStackSymbols.count; i++) {
        stackMessage = [stackMessage stringByAppendingFormat:@"%@\n", [callStackSymbols objectAtIndex:i]];
    }
    
    NSString *error = [NSString stringWithFormat:@"Exception Name: %@\nException Reason: %@\nException Stack:\n%@", exception.name, exception.reason, stackMessage];
    [[SFAppMonitor sharedMonitor] logError:error];
}



#pragma mark - Send

// 检查日志发送任务
- (void)checkLogs
{
    if (!self.isReachable || (_logSendWifiOnly && !self.isReachableViaWiFi)) {
        return;
    }
    
    NSDate *currentDate = [NSDate date];
    NSDate *lastSendDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastSendLogAppInfo];
    if (!lastSendDate || [currentDate timeIntervalSinceDate:lastSendDate] > _logSendInterval * 3600) {
        [self sendAppInfoLogs];
    }
    
    lastSendDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastSendLogLocation];
    if (!lastSendDate || [currentDate timeIntervalSinceDate:lastSendDate] > _logSendInterval * 3600) {
        [self sendLocationLogs];
    }
    
    lastSendDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastSendLogEvent];
    if (!lastSendDate || [currentDate timeIntervalSinceDate:lastSendDate] > _logSendInterval * 3600) {
        [self sendEventLogs];
    }
    
    lastSendDate = [[NSUserDefaults standardUserDefaults] valueForKey:kLastSendLogError];
    if (!lastSendDate || [currentDate timeIntervalSinceDate:lastSendDate] > _logSendInterval * 3600) {
        [self sendErrorLogs];
    }
}

// 发送APP信息
- (void)sendAppInfoLogs
{
    if (!_appInfoLogsArray.count) {
        return;
    }
    
//    NSString *path = [NSString stringWithFormat:@"mobilestatistics/uploadUserInfo.jsp?appKey=%@&mobileId=%@", AM_APPKEY, self.deviceUUID];
//    
//    NSDictionary *parameters = @{@"data": _appInfoLogsArray};
//    [[RequestCenter defaultCenter] startRequestWithPath:path userInfo:nil parameters:parameters success:^(ASIHTTPRequest *httpRequest, id JSONValue) {
//        if (httpRequest.responseString.trimmedString.integerValue == 1) {//发送成功
//            [_appInfoLogsArray removeAllObjects];
//            [SFFileManager deleteFile:kLogFilePathAppInfo];
//            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastSendLogAppInfo];
//        }
//    } failure:nil];
}

// 发送位置信息
- (void)sendLocationLogs
{
    if (!_locationLogsArray.count) {
        return;
    }
    
//    NSString *path = [NSString stringWithFormat:@"mobilestatistics/uploadPosition.jsp?appKey=%@&mobileId=%@", AM_APPKEY, self.deviceUUID];
//    
//    NSDictionary *parameters = @{@"data": _locationLogsArray};
//    [[RequestCenter defaultCenter] startRequestWithPath:path userInfo:nil parameters:parameters success:^(ASIHTTPRequest *httpRequest, id JSONValue) {
//        if (httpRequest.responseString.trimmedString.integerValue == 1) {//发送成功
//            [_locationLogsArray removeAllObjects];
//            [SFFileManager deleteFile:kLogFilePathLocation];
//            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastSendLogLocation];
//        }
//    } failure:nil];
}

// 发送事件日志
- (void)sendEventLogs
{
    if (!_eventLogsArray.count) {
        return;
    }
    
//    NSString *path = [NSString stringWithFormat:@"mobilestatistics/uploadEvent.jsp?appKey=%@&mobileId=%@", AM_APPKEY, self.deviceUUID];
//    
//    NSDictionary *parameters = @{@"data": _eventLogsArray};
//    [[RequestCenter defaultCenter] startRequestWithPath:path userInfo:nil parameters:parameters success:^(ASIHTTPRequest *httpRequest, id JSONValue) {
//        if (httpRequest.responseString.trimmedString.integerValue == 1) {//发送成功
//            [_eventLogsArray removeAllObjects];
//            [SFFileManager deleteFile:kLogFilePathEvent];
//            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastSendLogEvent];
//        }
//    } failure:nil];
}

// 发送错误日志
- (void)sendErrorLogs
{
    if (!_errorLogsArray.count) {
        return;
    }
    
//    NSString *path = [NSString stringWithFormat:@"mobilestatistics/uploadErrorLog.jsp?appKey=%@&mobileId=%@", AM_APPKEY, self.deviceUUID];
//    
//    NSDictionary *parameters = @{@"data": _errorLogsArray};
//    [[RequestCenter defaultCenter] startRequestWithPath:path userInfo:nil parameters:parameters success:^(ASIHTTPRequest *httpRequest, id JSONValue) {
//        if (httpRequest.responseString.trimmedString.integerValue == 1) {//发送成功
//            [_errorLogsArray removeAllObjects];
//            [SFFileManager deleteFile:kLogFilePathError];
//            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kLastSendLogError];
//        }
//    } failure:nil];
}



#pragma mark - Device

// 设备UDID   删除应用后重装ID不变
- (NSString *)deviceUDID
{
    return [[UIDevice currentDevice] UDID];
}

// 设备类型
- (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

// 系统名
- (NSString *)deviceSystemName
{
    return [[UIDevice currentDevice] systemName];
}

// 系统版本
- (NSString *)deviceSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

// 系统版本数值
- (CGFloat)deviceSystemVersionValue
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

// 是否已越狱
- (BOOL)isJailBroken
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]];
}

// 是否为iPad
- (BOOL)isIPad
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}



#pragma mark - App

// 程序名
- (NSString *)appName
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return appName;
}

// 程序ID bundleIdentifier
- (NSString *)appID
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

// 程序首个scheme
- (NSString *)appScheme
{
    NSDictionary *firstURLDictionary = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"] firstObject];
    return [[firstURLDictionary valueForKey:@"CFBundleURLSchemes"] firstObject];
}

// 程序版本
- (NSString *)appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

// 程序版本数值
- (CGFloat)appVersionValue
{
    return [[self appVersion] floatValue];
}


#pragma mark - Network

// 当前IP地址
- (NSString *)IPAddress
{
    char baseHostName[255];
    gethostname(baseHostName, 255); // 获得本机名字
    
    struct hostent *host = gethostbyname(baseHostName); // 将本机名字转换成主机网络结构体 struct hostent
    if (host) {
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
        char ip[255];
        strcpy(ip, inet_ntoa(*list[0]));  // 获得本机IP地址
        return [NSString stringWithUTF8String:ip];
    }
    return nil;
}

// 获取运营商信息
- (CellularProvider)cellularProvider
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    if ([mnc isEqualToString:@"00"] || [mnc isEqualToString:@"02"] || [mnc isEqualToString:@"07"]) {//移动
        return CellularProviderChinaMobile;
    } else if ([mnc isEqualToString:@"01"] || [mnc isEqualToString:@"06"]) {//联通
        return CellularProviderChinaUnicom;
    } else if ([mnc isEqualToString:@"03"] || [mnc isEqualToString:@"05"]) {// 电信
        return CellularProviderChinaTelecom;
    } else if ([mnc isEqualToString:@"20"]) {//铁通
        return CellularProviderChinaTietong;
    }
    return CellularProviderUnknown;
}

// 获取运营商名称
- (NSString *)cellularProviderName
{
    switch (self.cellularProvider) {
        case CellularProviderChinaMobile:
            return NSLocalizedString(@"中国移动", nil);
            break;
            
        case CellularProviderChinaUnicom:
            return NSLocalizedString(@"中国联通", nil);
            break;
            
        case CellularProviderChinaTelecom:
            return NSLocalizedString(@"中国电信", nil);
            break;
            
        case CellularProviderChinaTietong:
            return NSLocalizedString(@"中国铁通", nil);
            break;
            
        default:
            return NSLocalizedString(@"未知", nil);
            break;
    }
}

// 是否已连入互联网
- (BOOL)isReachable
{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

// 是否已连入蜂窝网络
- (BOOL)isReachableViaWWAN
{
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN];
}

// 是否已连入WiFi
- (BOOL)isReachableViaWiFi
{
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}

// 获取网络环境
- (NSString *)networkStatus
{
    switch ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]) {
        case AFNetworkReachabilityStatusUnknown:
            return NSLocalizedString(@"未知", nil);
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return NSLocalizedString(@"无网络", nil);
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return @"WWAN";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @"WiFi";
            break;
        default:
            return NSLocalizedString(@"未知", nil);
            break;
    }
}

@end
