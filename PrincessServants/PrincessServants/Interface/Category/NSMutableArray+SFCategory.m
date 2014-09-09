//
//  NSMutableArray+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSMutableArray+SFCategory.h"

@implementation NSMutableArray (SFCategory)

// 按数组元素的指定关键字(属性)、顺序和比较器进行排序
- (void)sortWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector
{
    [self sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key
                                                               ascending:ascending
                                                                selector:selector]]];
}

// 按数组元素的指定关键字(属性)和顺序进行排序
- (void)sortWithKey:(NSString *)key ascending:(BOOL)ascending
{
    SEL selector = nil;
    
    id value = [self.lastObject valueForKeyPath:key];
    if ([value respondsToSelector:@selector(localizedCaseInsensitiveCompare:)]) {
        selector = @selector(localizedCaseInsensitiveCompare:);
    } else if ([value respondsToSelector:@selector(caseInsensitiveCompare:)]) {
        selector = @selector(caseInsensitiveCompare:);
    } else if ([value respondsToSelector:@selector(compare:)]) {
        selector = @selector(compare:);
    }
    
    [self sortWithKey:key ascending:ascending selector:selector];
}

// 按数组元素的指定关键字(属性)进行升序排序
- (void)sortWithKey:(NSString *)key
{
    [self sortWithKey:key ascending:YES];
}

// 截取从index开始的count个元素的非空数组
- (NSMutableArray *)subarrayFromIndex:(NSUInteger)index count:(NSUInteger)count
{
    if (index < self.count) {
        NSUInteger length = MIN(self.count - index, count);
        return (length == self.count) ? self : [NSMutableArray arrayWithArray:[self subarrayWithRange:NSMakeRange(index, length)]];
    }
    return [NSMutableArray array];
}

@end
