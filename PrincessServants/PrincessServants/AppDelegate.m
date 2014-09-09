//
//  AppDelegate.m
//  PrincessServants
//
//  Created by tixa on 14-8-29.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "AppDelegate.h"
#import "PSTabBarViewController.h"
#import "Managers.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s:", __FUNCTION__);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.0) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupRootView) name:@"AccountDidChangeNotification" object:nil];
    // 初始化单例
    [self setupDefaultManager];
    
#if TARGET_IPHONE_SIMULATOR
    
#else
    [[SFAppMonitor sharedMonitor] logAppInfo]; // 初始化数据统计，记录设备信息
    [[SFAppMonitor sharedMonitor] logEventWithModuleName:@"AppStart" eventName:@"AppStart"]; // 记录程序启动
    [[SFAppMonitor sharedMonitor] setEnableErrorLog:YES];
    
    // 首次启动APP
    if ([[SFConfigCenter defaultCenter] isFirstStartup]) {
        [[SFAppMonitor sharedMonitor] logEventWithModuleName:@"AppInstall" eventName:@"AppInstall"]; // 记录程序安装
    }
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
//    NSLog(@"%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    
    [self setupRootView];
    
    [self.window makeKeyAndVisible];
    
    
    // 注册远程通知
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OpenPush"]) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    return YES;
}

- (void)setupDefaultManager
{
    // 初始化单例
//    [[DataManager defaultManager] setupUserDefaults];
    [RequestCenter defaultCenter];
    [SystemLocationCenter defaultCenter];
    [AudioCenter defaultCenter];
    [SFConfigCenter defaultCenter];
    [AccountCenter defaultCenter];
    [SFContactCenter defaultCenter];
    [SFAppMonitor sharedMonitor];
    [[ViewCenter defaultCenter] setupAppearance]; // 程序外观
    [ImageCache sharedCache];
    [DatabaseCenter defaultCenter];
    
}

- (void)setupRootView
{
    PSTabBarViewController *tab = [[PSTabBarViewController alloc] init];
    self.window.rootViewController = tab;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%s:", __FUNCTION__);
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"%s:", __FUNCTION__);
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s:", __FUNCTION__);
    // 清空图标badget
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
#if TARGET_IPHONE_SIMULATOR
    
#else
    [[SFAppMonitor sharedMonitor] checkLogs];
#endif
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s:", __FUNCTION__);
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s:", __FUNCTION__);
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end
