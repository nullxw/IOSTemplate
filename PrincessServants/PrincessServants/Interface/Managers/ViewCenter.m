//
//  ViewCenter.m
//  ShadowFiend
//
//  Created by tixa on 14-7-1.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "ViewCenter.h"

NSString *const ThemeDidChangeNotification = @"ThemeDidChange";

@interface ViewCenter ()

@end

@implementation ViewCenter

static ViewCenter *defaultCenterInstance = nil;

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
        // 如果没有设置主题则设置默认主题
        if (self.themeID == 0) {
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"ThemeID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    return self;
}

#pragma mark - Property

// 主题ID
- (NSInteger)themeID
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ThemeID"];
}

- (void)setThemeID:(NSInteger)themeID
{
    [[NSUserDefaults standardUserDefaults] setInteger:themeID forKey:@"ThemeID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeDidChangeNotification object:nil];
}

// 主题默认色16进制值
- (NSString *)themeHexRGBString
{
    switch (self.themeID) {
        case 1: // 棕色
            return @"612905";
            break;
            
        case 2: // 绿
            return @"25bd07";
            break;
            
        case 3: // 橙
            return @"f3940a";
            break;
            
        default:
            return @"";
            break;
    }
}

// 主题默认色调
- (UIColor *)themeColor
{
    return [UIColor colorWithHexRGB:self.themeHexRGBString];
}

#pragma mark - Appearance

// iOS7以前版本,重新设置外观
- (void)setupAppearance
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version>=7.0) {  // iOS7及以上
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:42/255.0 green:183/255.0 blue:166/255.0 alpha:1.0]];
        [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:42/255.0 green:183/255.0 blue:166/255.0 alpha:1.0]];
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        
    }else{  // iOS6
        // 导航栏背景
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:42/255.0 green:183/255.0 blue:166/255.0 alpha:1.0] size:CGSizeMake(1, 44)] forBarMetrics:UIBarMetricsDefault];
        // 其他导航栏左右两侧按钮
        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init]
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        // 返回按钮
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"sf_navibar_back_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 0) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        // 返回按钮偏移量
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, 0)
                                                             forBarMetrics:UIBarMetricsDefault];
        // UITabBar
        [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:42/255.0 green:183/255.0 blue:166/255.0 alpha:1.0] size:CGSizeMake(1, 49)]];
        [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                            UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                                            UITextAttributeTextColor:[UIColor whiteColor]}
                                                 forState:UIControlStateSelected];
        [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                            UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                                            UITextAttributeTextColor:[UIColor blueColor]}
                                                 forState:UIControlStateNormal];
        // UISegmentedControl
        [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0] size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateSelected
                                                 barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateNormal
                                                 barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setDividerImage:[UIImage imageWithColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0] size:CGSizeMake(1, 29)]
                                     forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateSelected
                                              barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0],
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] }
                                                       forState:UIControlStateNormal];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor:[UIColor whiteColor],
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]}
                                                       forState:UIControlStateSelected];
    }
    
    // 统一设置的
    // 导航栏标题字体大小颜色阴影偏移量
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{ NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
        UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]}];
    // 导航栏按钮字体大小阴影偏移量
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     @{ UITextAttributeFont: [UIFont systemFontOfSize:17],
        UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]} forState:UIControlStateNormal];
    
    //页签
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor darkGrayColor]];
    
}

@end
