//
//  NSURL+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "NSURL+SFCategory.h"

@implementation NSURL (SFCategory)

// 获取参数字典
- (NSDictionary *)parameterDictionary
{
    NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    for (NSString *paraString in [self.query componentsSeparatedByString:@"&"]) {
        NSRange equalRange = [paraString rangeOfString:@"="];
        if (equalRange.length) {
            NSString *paraKey = [paraString substringToIndex:equalRange.location];
            NSString *paraValue = [paraString substringFromIndex:equalRange.location + 1];
            if (paraKey.length) {
                [parameterDictionary setValue:paraValue forKey:paraKey];
            }
        }
    }
    return parameterDictionary;
}

// 获取指定参数值
- (NSString *)valueForParameter:(NSString *)parameter
{
    return [[self parameterDictionary] valueForKey:parameter];
}

@end
