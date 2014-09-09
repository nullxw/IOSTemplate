//
//  NSArray+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSArray+SFCategory.h"
#import "NSDictionary+SFCategory.h"

@implementation NSArray (SFCategory)

// 获取相对于指定数组增删的元素，用于同步计算
- (NSDictionary *)synchronizedDictionaryWithBaseArray:(NSArray *)baseArray
{
    NSMutableArray *deletedArray = [NSMutableArray array]; // 记录删除的元素
    NSMutableArray *updateArray  = [NSMutableArray array]; // 记录其他的元素
    NSMutableArray *createdArray = [NSMutableArray arrayWithArray:baseArray]; // 记录新增的元素
    
    for (id object in self) {
        if ([createdArray containsObject:object]) {
            [createdArray removeObject:object];
            [updateArray addObject:object];
        } else {
            [deletedArray addObject:object];
        }
    }
    return @{@"delete": deletedArray, @"create": createdArray, @"update": updateArray};
}

- (NSMutableArray *)mutableDeepCopy
{
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[self count]]; // 预分配了一个[self count]大的空间来存储
    
    for (id value in self)    // 快速枚举，循环所有keys
    {
        id oneValue = value;  // 设置oneValue为源值
        
        id oneCopy = nil;
        
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)])
        {
            oneCopy = [oneValue mutableDeepCopy];
        } else if ([oneValue respondsToSelector:@selector(mutableCopyWithZone:)]) {
            
            oneCopy = [oneValue mutableCopy];
        }
        
        if (oneCopy == nil) {
            oneCopy = [oneValue copy];
        }
        [ret addObject:oneCopy];
    }
    
    return ret;
}

@end
