//
//  NSString+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SFCategory)

- (NSString *)documentFilePath;             // 转换为沙箱Documents文件夹下的路径
- (BOOL)isDocumentFilePath;                 // 是否为沙箱Documents文件夹下的路径

- (NSString *)cacheFilePath;                // 转换为沙箱Library/Cache文件夹下的路径
- (BOOL)isCacheFilePath;                    // 是否为沙箱Library/Cache文件夹下的路径

/**
 *  超过maxLength长度的字符串部分会以"..."代替
 *
 *  @param maxLength 最长长度
 *
 *  @return a substring   返回字符串长度为maxLength+@"..."
 */
- (NSString *)substringWithMaxLength:(NSUInteger)maxLength;

- (NSString *)trimmedString;                // 去除空格、换行和\r\n
- (NSString *)UTF8EncodedString;            // 编码UTF8字符串
- (NSString *)GBKEncodedString;             // 编码GBK字符串，并处理常见URL特殊字符
- (NSString *)MD5EncodedString;             // 编码MD5字符串
- (NSString *)numberString;                 // 转换为T9数字键盘对应的数字串

- (BOOL)isValidPhone;                       // 是否为合法手机号  规则待完善
- (BOOL)isValidEmail;                       // 是否为合法邮箱地址  规则待完善
- (BOOL)isValidImageURL;                    // 是否为合法图片路径
- (BOOL)isValidVideoURL;                    // 是否为合法视频路径
- (BOOL)isValidAudioURL;                    // 是否为合法音频路径
- (BOOL)isValidWebURL;                      // 是否为合法web链接
- (BOOL)isValidBrowseURL;                   // 是否为合法用webview打开路径

/**
 *  根据字符串和属性描述动态计算宽高
 *
 *  @param size       宽高约束
 *  @param options    一般选NSStringDrawingUsesLineFragmentOrigin
 *  @param attributes 属性描述字典  一般只设置NSFontAttributeName对应的键值对即可
 *  @param context    一般传递nil即可
 *
 *  @return 所占空间rect
 */
-(CGRect)myBoundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context;

@end
