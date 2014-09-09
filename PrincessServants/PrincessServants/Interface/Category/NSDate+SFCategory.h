//
//  NSDate+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SFCategory)

- (NSString *)timeIntervalDescription;      // 距离当前的时间间隔描述  参考日期[NSDate date]
- (NSString *)minuteDescription;            // 精确到分钟的日期描述  参考日期[NSDate date]
- (NSString *)formattedDateDescription;     // 格式化日期描述  参考日期[NSDate date]

@end
