//
//  NSDictionary+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSDictionary+SFCategory.h"
#import "NSDateFormatter+SFCategory.h"
#import "NSArray+SFCategory.h"

@implementation NSDictionary (SFCategory)

// 指定key和class的value
- (id)valueForKey:(NSString *)key withClass:(__unsafe_unretained Class)aClass
{
    id value = [self valueForKey:key];
    return [value isKindOfClass:aClass] ? value : nil;
}

- (NSInteger)integerForKey:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

- (CGFloat)floatForKey:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0.0;
}

- (double)doubleForKey:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0.0;
}

- (NSString *)stringForKey:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    } else {
        return [value description];
    }
}

// 非nil字符串
- (NSString *)safeStringForKey:(NSString *)key
{
    NSString *stringValue = [self stringForKey:key];
    return stringValue ? stringValue : @"";
}

// 内容为整型值的字符串
- (NSString *)integerStringForKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%d", [self integerForKey:key]];
}

- (NSURL *)urlForKey:(NSString *)key
{
    return [NSURL URLWithString:[self stringForKey:key]];
}

// 日期(可处理NSDate对象、秒数或毫秒数、"yyyy-MM-dd HH:mm:ss"格式字符串)
- (NSDate *)dateForKey:(NSString *)key isMS:(BOOL)isMS
{
    id value = [self valueForKey:key];
    if ([value isKindOfClass:[NSDate class]]) {
        return value;
    }
    
    // 判断日期格式
    if ([value isKindOfClass:[NSString class]]) {
        NSDate *date = [[NSDateFormatter defaultDateFormatter] dateFromString:value];
        if (date) {// 非规范日期格式直接进行间隔转换
            return date;
        }
    }
    
    // 转换时间间隔
    if ([value respondsToSelector:@selector(doubleValue)]) {
        double doubleValue = [value doubleValue];
        doubleValue = isMS ? doubleValue / 1000.0 : doubleValue;
        return [NSDate dateWithTimeIntervalSince1970:doubleValue];
    }
    return nil;
}

- (NSDate *)dateForKey:(NSString *)key
{
    return [self dateForKey:key isMS:NO];
}

- (NSDate *)dateForMSKey:(NSString *)key
{
    return [self dateForKey:key isMS:YES];
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [self valueForKey:key withClass:[NSArray class]];
}

- (NSMutableArray *)mutableArrayForKey:(NSString *)key
{
    NSArray *array = [self valueForKey:key withClass:[NSArray class]];
    return array ? [NSMutableArray arrayWithArray:array] : nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    return [self valueForKey:key withClass:[NSDictionary class]];
}

- (NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key
{
    NSDictionary *dictionary = [self valueForKey:key withClass:[NSDictionary class]];
    return dictionary ? [NSMutableDictionary dictionaryWithDictionary:dictionary] : nil;
}

- (NSMutableDictionary *)mutableDeepCopy

{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];  // 预分配了一个[self count]大的空间来存储
    
    NSArray *keys = [self allKeys];
    
    for (id key in keys)    // 快速枚举，循环所有keys
    {
        id oneValue = [self valueForKey:key];  // 设置oneValue为源值
        
        id oneCopy = nil;
        
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)])
            
            oneCopy = [oneValue mutableDeepCopy];
        
        else if ([oneValue respondsToSelector:@selector(mutableCopyWithZone:)])
            
            oneCopy = [oneValue mutableCopy];
        
        if (oneCopy == nil)
            
            oneCopy = [oneValue copy];
        
        [ret setValue:oneCopy forKey:key];
        
    }
    
    return ret;
    
}

@end
