//
//  UIColor+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UIColor+SFCategory.h"

@implementation UIColor (SFCategory)

// 由16进制字符串获取颜色
+ (UIColor *)colorWithHexRGB:(NSString *)hexRGBString
{
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (hexRGBString) {
        NSScanner *scanner = [NSScanner scannerWithString:hexRGBString];
        [scanner scanHexInt:&colorCode];
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    
    return [UIColor colorWithRed:(float)redByte/0xff green:(float)greenByte/0xff blue:(float)blueByte/0xff alpha:1.0];
}

+ (UIColor *)whiteTranslucentColor
{
	return [UIColor colorWithWhite:1.0 alpha:0.9];
}

+ (UIColor *)blackTranslucentColor
{
	return [UIColor colorWithWhite:0.0 alpha:0.9];
}

+ (UIColor *)skyBlueColor
{
	return [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
}

+ (UIColor *)lightBlueColor
{
	return [UIColor colorWithRed:0.0 green:0.75 blue:1.0 alpha:1.0];
}

+ (UIColor *)darkGreenColor
{
	return [UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:1.0];
}

+ (UIColor *)pinkColor
{
	return [UIColor colorWithRed:1.0 green:0.2 blue:0.6 alpha:1.0];
}

// 浅灰内容背景色
+ (UIColor *)lightGrayBGColor
{
    return [self colorWithHexRGB:@"e2e2dc"];
}

@end
