//
//  ViewCenter.h
//  ShadowFiend
//
//  Created by tixa on 14-7-1.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

extern NSString *const ThemeDidChangeNotification;

@interface ViewCenter : SFObject

@property (nonatomic) NSInteger themeID;                                           // 主题ID
@property (nonatomic, strong, readonly) NSString *themeHexRGBString;               // 主题默认色16进制值
@property (nonatomic, strong, readonly) UIColor *themeColor;                       // 主题默认色调


+ (instancetype)defaultCenter;

// 统一设置iOS7以前的控件样式
- (void)setupAppearance;

@end
