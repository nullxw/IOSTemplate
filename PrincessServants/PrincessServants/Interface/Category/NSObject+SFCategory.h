//
//  NSObject+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SFCategory)

// 判定SEL是否可执行，去除ARC警告
- (void)performSafeSelector:(SEL)aSelector;
- (void)performSafeSelector:(SEL)aSelector withObject:(id)object;
- (void)performSafeSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

@end
