//
//  UIScrollView+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (SFCategory)

- (void)scrollToTop;                                 // 滑动至顶部
- (void)scrollToTopAnimated:(BOOL)animated;

- (void)scrollToBottom;                              // 滑动至底部
- (void)scrollToBottomAnimated:(BOOL)animated;

- (void)scrollToRightAnimated:(BOOL)animated;        // 滑动至右边界

- (void)scrollRectToTop:(CGRect)rect animated:(BOOL)animated;  // 滑动使指定rect置顶

@end
