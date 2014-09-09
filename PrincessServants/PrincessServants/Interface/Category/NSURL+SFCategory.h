//
//  NSURL+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SFCategory)

- (NSDictionary *)parameterDictionary;                   // 获取参数字典
- (NSString *)valueForParameter:(NSString *)parameter;   // 获取指定参数值

@end
