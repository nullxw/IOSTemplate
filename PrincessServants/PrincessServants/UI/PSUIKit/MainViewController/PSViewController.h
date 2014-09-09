//
//  PSViewController.h
//  PrincessServants
//
//  Created by tixa on 14-9-4.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCategory.h"

@interface PSViewController : UIViewController
{
    // 标记和状态
    NSUInteger           _tag;                   // 标记
    CGFloat              _systemVersion;         // 当前iOS SDK版本信息
    
    // 视图
    UIView              *_contentView;           // 内容视图   默认clearColor
    UINavigationBar     *_navigationBar;         // 导航条     如果不在导航控制器中,自动加上导航条
    
    // 视图控制
    UIColor             *_backgroundColor;       // self.view背景色  默认whiteColor
    BOOL                 _showNavigationBar;     // 是否显示导航栏控件
    BOOL                 _showBackBarButtonItem; // 是否显示导航栏返回按钮 默认NO
    
}


// 标记和状态
@property (nonatomic)                   NSUInteger           tag;                  // 标记
@property (nonatomic, readonly)         CGFloat              systemVersion;        // 当前iOS SDK版本信息
@property (nonatomic, weak)             PSViewController    *superViewController;  // 父控制器


// 视图
@property (nonatomic, readonly)         UINavigationBar     *navigationBar;        // 导航条 如果不在导航控制器中,加上的导航条


// 视图控制
@property (nonatomic, strong)           UIColor             *backgroundColor;      // self.view背景色  默认whiteColor
@property (nonatomic)                   BOOL                 showNavigationBar;    // 是否显示自己添加上的导航栏控件  默认NO
@property (nonatomic)                   BOOL                 showBackBarButtonItem;// 是否显示导航栏返回按钮  默认NO


- (void)setupSubviews;

// 释放前的清除操作
- (void)willDealloc;

// 显示加载视图
- (void)showLoadingView;
- (void)showLoadingViewWithTitle:(NSString *)title;
// 隐藏加载视图
- (void)hideLoadingView;

// 设置导航栏左侧按钮
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems;
// 设置导航栏右侧按钮
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems;

// 默认返回按钮样式(dismiss或pop)
- (UIBarButtonItem *)defaultBackBarButtonItem;
// 默认返回按钮样式
- (UIBarButtonItem *)defaultBackBarButtonItemWithTarget:(id)target action:(SEL)action;

@end
