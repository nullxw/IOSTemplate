//
//  NSArray+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SFCategory)

/**
 *  @brief  获取相对于指定数组增删的元素,用于同步计算
 *  @param  baseArray   用于同步比较的基准数组(是初始数组添加或者删除一些元素之后的数组)  self是初始数组
 *  @return 返回记录增删元素集的字典,其Key分别为@"delete"和@"create"
 *          @"delete"Key对应的数组里面存放的是:self数组转变成baseArray数组这个转变过程中删除掉的元素
 *          @"create"Key对应的数组里面存放的是:self数组转变成baseArray数组这个转变过程中新添加的元素
 *          @"update"Key对应的数组里面存放的是:self数组转变成baseArray数组这个转变过程中没有既没有被删除也不是新添加的元素
 */
- (NSDictionary *)synchronizedDictionaryWithBaseArray:(NSArray *)baseArray;

- (NSMutableArray *)mutableDeepCopy;

@end
