//
//  NSDictionary+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SFCategory)

- (id)valueForKey:(NSString *)key
        withClass:(__unsafe_unretained Class)aClass;    // 指定key和class的value,默认为nil

- (NSInteger)integerForKey:(NSString *)key;             // 返回对象integerValue,默认为0
- (CGFloat)floatForKey:(NSString *)key;                 // 返回对象floatValue,默认为0.0
- (double)doubleForKey:(NSString *)key;                 // 返回对象doubleValue,默认为0.0

- (NSString *)stringForKey:(NSString *)key;             // 若非NSString类型,返回对象stringValue或description,默认为nil
- (NSString *)safeStringForKey:(NSString *)key;         // 返回非nil字符串,默认为@""
- (NSString *)integerStringForKey:(NSString *)key;      // 返回内容为整型值的字符串,默认为@"0"

- (NSURL *)urlForKey:(NSString *)key;

- (NSDate *)dateForKey:(NSString *)key;                 // 返回日期,默认为nil(可处理NSDate对象、秒数、"yyyy-MM-dd HH:mm:ss"格式字符串)
- (NSDate *)dateForMSKey:(NSString *)key;               // 返回日期,默认为nil(可处理NSDate对象、毫秒数、"yyyy-MM-dd HH:mm:ss"格式字符串)

- (NSArray *)arrayForKey:(NSString *)key;                           // 默认为nil
- (NSMutableArray *)mutableArrayForKey:(NSString *)key;             // 默认为nil

- (NSDictionary *)dictionaryForKey:(NSString *)key;                 // 默认为nil
- (NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key;   // 默认为nil

- (NSMutableDictionary *)mutableDeepCopy;

@end
