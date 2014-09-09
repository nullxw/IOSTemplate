//
//  PSPerson.h
//  PrincessServants
//
//  Created by tixa on 14-9-5.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

@interface PSPerson : SFObject

@property (nonatomic, strong) NSString   *ID;
@property (nonatomic, strong) NSString   *name;
@property (nonatomic, strong) NSString   *age;
@property (nonatomic, strong) NSString   *phone;    // 电话
@property (nonatomic, strong) NSString   *email;    // 邮箱
@property (nonatomic, strong) NSString   *distance; // 距离
@property (nonatomic, strong) NSString   *info;     // 简介

@end
