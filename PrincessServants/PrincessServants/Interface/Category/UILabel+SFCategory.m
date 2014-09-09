//
//  UILabel+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UILabel+SFCategory.h"
#import "NSString+SFCategory.h"

@implementation UILabel (SFCategory)

- (instancetype)initWithFrame:(CGRect)frame
               text:(NSString *)text
               font:(UIFont *)font
          textColor:(UIColor *)textColor
        shadowColor:(UIColor *)shadowColor
       shadowOffset:(CGSize)shadowOffset
    autoresizeWidth:(BOOL)autoresizeWidth
   autoresizeHeight:(BOOL)autoresizeHeight
{
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.highlightedTextColor = [UIColor whiteColor];
        self.textColor = textColor;
        
        self.font = font;
        self.text = text;
        
        if (shadowColor) {
            self.shadowColor = shadowColor;
            self.shadowOffset = shadowOffset;
        }
        
        if (autoresizeHeight) {
            self.numberOfLines = 0;
            self.lineBreakMode = NSLineBreakByCharWrapping;
        }
        
        if (autoresizeWidth || autoresizeHeight) {
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
            CGRect rect = [text myBoundingRectWithSize:CGSizeMake(frame.size.width, 9999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
            CGRect aFrame = frame;
            aFrame.size.width = autoresizeWidth ? rect.size.width : aFrame.size.width;
            aFrame.size.height = autoresizeHeight ? rect.size.height : aFrame.size.height;
            self.frame = aFrame;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
               text:(NSString *)text
               font:(UIFont *)font
          textColor:(UIColor *)textColor
    autoresizeWidth:(BOOL)autoresizeWidth
   autoresizeHeight:(BOOL)autoresizeHeight
{
    return [self initWithFrame:frame
                          text:text
                          font:font
                     textColor:textColor
                   shadowColor:nil
                  shadowOffset:CGSizeZero
               autoresizeWidth:autoresizeWidth
              autoresizeHeight:autoresizeHeight];
}

+ (instancetype)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                       font:(UIFont *)font
                  textColor:(UIColor *)textColor
            autoresizeWidth:(BOOL)autoresizeWidth
           autoresizeHeight:(BOOL)autoresizeHeight
{
    return [[self alloc] initWithFrame:frame
                                  text:text
                                  font:font
                             textColor:textColor
                       autoresizeWidth:autoresizeWidth
                      autoresizeHeight:autoresizeHeight];
}

+ (CGFloat)heightWithFrame:(CGRect)frame
                      text:(NSString *)text
                      font:(UIFont *)font
          autoresizeHeight:(BOOL)autoresizeHeight
{
    if (autoresizeHeight) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        CGRect rect = [text myBoundingRectWithSize:CGSizeMake(frame.size.width, 9999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return rect.size.height;
    } else {
        return frame.size.height;
    }
}

#pragma mark - Style

// 标题样式标签
+ (instancetype)titleLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    return [self labelWithFrame:frame
                           text:text
                           font:FONT_TITLE
                      textColor:[UIColor blackColor]
                autoresizeWidth:NO
               autoresizeHeight:NO];
}

// 子标题样式标签
+ (instancetype)subtitleLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    return [self labelWithFrame:frame
                           text:text
                           font:FONT_SUBTITLE
                      textColor:[UIColor grayColor]
                autoresizeWidth:NO
               autoresizeHeight:NO];
}

@end
