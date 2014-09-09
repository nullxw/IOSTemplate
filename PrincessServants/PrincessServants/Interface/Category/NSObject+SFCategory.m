//
//  NSObject+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSObject+SFCategory.h"

@implementation NSObject (SFCategory)

// 判定SEL是否可执行，去除ARC警告
- (void)performSafeSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
{
    if ([self respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (object2) {
            [self performSelector:aSelector withObject:object1 withObject:object2];
        } else if (object1) {
            [self performSelector:aSelector withObject:object1];
        } else {
            [self performSelector:aSelector];
        }
#pragma clang diagnostic pop
    }
}

// 判定SEL是否可执行，去除ARC警告
- (void)performSafeSelector:(SEL)aSelector withObject:(id)object
{
    [self performSafeSelector:aSelector withObject:object withObject:nil];
}

// 判定SEL是否可执行，去除ARC警告
- (void)performSafeSelector:(SEL)aSelector
{
    [self performSafeSelector:aSelector withObject:nil withObject:nil];
}

@end
