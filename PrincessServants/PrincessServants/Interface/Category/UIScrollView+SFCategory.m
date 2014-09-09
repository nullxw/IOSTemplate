//
//  UIScrollView+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UIScrollView+SFCategory.h"

@implementation UIScrollView (SFCategory)

// 滑动至顶部
- (void)scrollToTopAnimated:(BOOL)animated
{
    [self scrollRectToVisible:CGRectMake(0.0, 0.0, self.bounds.size.width, 1.0) animated:animated];
}

// 滑动至顶部
- (void)scrollToTop
{
    [self scrollToTopAnimated:YES];
}

// 滑动至底部
- (void)scrollToBottomAnimated:(BOOL)animated
{
    CGRect rect = self.bounds;
    rect.origin.y = MAX(self.contentSize.height, rect.size.height) - rect.size.height;
    [self scrollRectToVisible:rect animated:animated];
}

// 滑动至底部
- (void)scrollToBottom
{
    [self scrollToBottomAnimated:YES];
}

// 滑动至右边界
- (void)scrollToRightAnimated:(BOOL)animated
{
    CGRect rect = self.bounds;
    rect.origin.x = self.contentSize.width - rect.size.width;
    [self scrollRectToVisible:rect animated:animated];
}

// 滑动使指定rect置顶
- (void)scrollRectToTop:(CGRect)rect animated:(BOOL)animated
{
    CGRect tRect = self.bounds;
    tRect.origin.y = MIN(rect.origin.y, self.contentSize.height - tRect.size.height);
    tRect.origin.y = MAX(tRect.origin.y, 0.0);
    [self scrollRectToVisible:tRect animated:animated];
}

@end
