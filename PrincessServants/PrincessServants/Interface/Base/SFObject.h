//
//  SFObject.h
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCategory.h"

@interface SFObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary;

// 序列化
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
