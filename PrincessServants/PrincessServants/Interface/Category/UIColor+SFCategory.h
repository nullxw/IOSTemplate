//
//  UIColor+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SFCategory)

+ (UIColor *)colorWithHexRGB:(NSString *)hexRGBString;

+ (UIColor *)whiteTranslucentColor;
+ (UIColor *)blackTranslucentColor;

+ (UIColor *)skyBlueColor;
+ (UIColor *)lightBlueColor;
+ (UIColor *)darkGreenColor;
+ (UIColor *)pinkColor;

+ (UIColor *)lightGrayBGColor;     // 浅灰内容背景色

@end
