//
//  AccountCenter.m
//  PrincessServants
//
//  Created by tixa on 14-9-1.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "AccountCenter.h"
#import "SFFileManager.h"

#define kLoginAccountID     @"LoginAccountID"
#define kFilePathAccount    @"AccountCenter/AccountFile"

@interface AccountCenter ()
{
    NSMutableDictionary *_accountsDictionary; //账户字典
}

@end

@implementation AccountCenter

static AccountCenter *defaultCenterInstance = nil;

+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultCenterInstance = [[self alloc] init];
        });
    }
    return defaultCenterInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _accountsDictionary = [SFFileManager loadDictionary:kFilePathAccount];
    }
    return self;
}

// 当前登录账户ID
- (NSString *)loginAccountID
{
    NSString *accountID = [[NSUserDefaults standardUserDefaults] stringForKey:kLoginAccountID];
    if (accountID.length>0) {
        return accountID;
    }else{
        return @"";
    }
}

- (PSAccount *)loginAccount
{
    return [self queryAccountWithAccountID:[self loginAccountID]];
}

// 获取账户
- (PSAccount *)queryAccountWithAccountID:(NSString *)accountID
{
    if (accountID.length == 0) return nil;
    return [_accountsDictionary valueForKey:accountID];
}

@end
