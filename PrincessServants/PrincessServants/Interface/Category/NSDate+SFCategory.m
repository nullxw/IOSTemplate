//
//  NSDate+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSDate+SFCategory.h"
#import "NSDateFormatter+SFCategory.h"

@implementation NSDate (SFCategory)

// 距离当前的时间间隔描述
- (NSString *)timeIntervalDescription
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
	if (timeInterval < 60) {
        return [NSString stringWithFormat:@"1%@", NSLocalizedString(@"分钟内", nil)];
	} else if (timeInterval < 3600) { // 1小时内
        return [NSString stringWithFormat:@"%.f%@", timeInterval / 60, NSLocalizedString(@"分钟前", nil)];
	} else if (timeInterval < 86400) { // 1天内
        return [NSString stringWithFormat:@"%.f%@", timeInterval / 3600, NSLocalizedString(@"小时前", nil)];
	} else if (timeInterval < 2592000) { // 30天内
        return [NSString stringWithFormat:@"%.f%@", timeInterval / 86400, NSLocalizedString(@"天前", nil)];
    } else if (timeInterval < 31536000) { // 30天至1年内
        NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"M月d日"];
        return [dateFormatter stringFromDate:self];
    } else {
        return [NSString stringWithFormat:@"%.f%@", timeInterval / 31536000, NSLocalizedString(@"年前", @"多少年以前")];
    }
}

// 精确到分钟的日期描述
- (NSString *)minuteDescription
{
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    
	NSString *theDay = [dateFormatter stringFromDate:self]; // 日期的年月日
	NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]]; // 当前年月日
    if ([theDay isEqualToString:currentDay]) { // 当天
		[dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
	} else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) { // 昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"昨天", nil), [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < 86400 * 7) { // 间隔一周内
        [dateFormatter setDateFormat:@"EEEE ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else {//以前
		[dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
	}
}

// 格式化日期描述
- (NSString *)formattedDateDescription
{
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    
	NSString *theDay = [dateFormatter stringFromDate:self]; // 日期的年月日
	NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]]; // 当前年月日
    
    NSTimeInterval interval = -[self timeIntervalSinceNow];
    NSInteger timeInterval = (NSInteger)interval;
    if (timeInterval < 60) {
        return [NSString stringWithFormat:@"1%@", NSLocalizedString(@"分钟内", nil)];
	} else if (timeInterval < 3600) { // 1小时内
        return [NSString stringWithFormat:@"%d%@", timeInterval / 60, NSLocalizedString(@"分钟前", nil)];
	} else if (timeInterval < 21600) { // 6小时内
        return [NSString stringWithFormat:@"%d%@", timeInterval / 3600, NSLocalizedString(@"小时前", nil)];
	} else if ([theDay isEqualToString:currentDay]) { // 当天
		[dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"今天", nil), [dateFormatter stringFromDate:self]];
	} else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) { // 昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"昨天", nil), [dateFormatter stringFromDate:self]];
    } else { // 以前
		[dateFormatter setDateFormat:@"MM-dd HH:mm"];
        return [dateFormatter stringFromDate:self];
	}
}

@end
