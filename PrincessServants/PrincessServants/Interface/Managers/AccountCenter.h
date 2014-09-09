//
//  AccountCenter.h
//  PrincessServants
//
//  Created by tixa on 14-9-1.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFObject.h"
#import "PSAccount.h"

@interface AccountCenter : SFObject

+ (instancetype)defaultCenter;

// 当前登录账户ID  返回结果不会为nil,有可能为@""
- (NSString *)loginAccountID;
// 当前登录账户
- (PSAccount *)loginAccount;

// 获取账户  结果有可能为nil
- (PSAccount *)queryAccountWithAccountID:(NSString *)accountID;

@end
