//
//  UILabel+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (SFCategory)

// 可自适应文本的宽和高
- (instancetype)initWithFrame:(CGRect)frame
               text:(NSString *)text
               font:(UIFont *)font
          textColor:(UIColor *)textColor
    autoresizeWidth:(BOOL)autoresizeWidth
   autoresizeHeight:(BOOL)autoresizeHeight;

// 可自适应文本的宽和高,可设置阴影
- (instancetype)initWithFrame:(CGRect)frame
               text:(NSString *)text
               font:(UIFont *)font
          textColor:(UIColor *)textColor
        shadowColor:(UIColor *)shadowColor
       shadowOffset:(CGSize)shadowOffset
    autoresizeWidth:(BOOL)autoresizeWidth
   autoresizeHeight:(BOOL)autoresizeHeight;

// 标题样式标签
+ (instancetype)titleLabelWithFrame:(CGRect)frame text:(NSString *)text;

// 子标题样式标签
+ (instancetype)subtitleLabelWithFrame:(CGRect)frame text:(NSString *)text;


@end
