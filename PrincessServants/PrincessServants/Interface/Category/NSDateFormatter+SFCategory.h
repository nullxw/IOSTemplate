//
//  NSDateFormatter+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (SFCategory)

+ (instancetype)dateFormatter;           // 返回创建的一个默认对象  并未设置dateFormat

+ (instancetype)dateFormatterWithFormat:(NSString *)dateFormat;

+ (instancetype)defaultDateFormatter;    //yyyy-MM-dd HH:mm:ss

@end
