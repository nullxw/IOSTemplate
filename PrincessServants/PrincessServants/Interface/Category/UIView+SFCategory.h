//
//  UIView+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SFCategory)

- (void)startShakeAnimation;      // 摇动动画
- (void)stopShakeAnimation;

- (void)startRotateAnimation;     // 360°旋转动画
- (void)stopRotateAnimation;

- (UIImage *)screenshot;          // 截图

@end
