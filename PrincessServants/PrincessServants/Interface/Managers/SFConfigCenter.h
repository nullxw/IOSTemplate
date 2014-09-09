//
//  SFConfigCenter.h
//  PrincessServants
//
//  Created by tixa on 14-9-1.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

@interface SFConfigCenter : SFObject

@property (nonatomic)         BOOL                 isFirstStartup;          // 是否是第一次运行软件
@property (nonatomic)         BOOL                 isOpenSound;             // 是否开启声音
@property (nonatomic)         BOOL                 isOpenVibrate;           // 是否开启震动

+ (instancetype)defaultCenter;

@end
