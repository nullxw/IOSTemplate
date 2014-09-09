//
//  PSAccount.h
//  PrincessServants
//
//  Created by tixa on 14-9-5.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"

@interface PSAccount : SFObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phone;  // 用户电话
@property (nonatomic, strong) NSString *email;  // 用户邮箱

@end
