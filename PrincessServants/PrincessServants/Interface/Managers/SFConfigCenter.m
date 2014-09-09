//
//  SFConfigCenter.m
//  PrincessServants
//
//  Created by tixa on 14-9-1.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFConfigCenter.h"
#import "AccountCenter.h"

static SFConfigCenter *defaultCenterInstance = nil;

@interface SFConfigCenter ()

@end

@implementation SFConfigCenter

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
        
        // 第一次启动
        id up = [[NSUserDefaults standardUserDefaults] objectForKey:@"config/isFirstStartup"];
        self.isFirstStartup  = up ? [up boolValue] : YES;
        // 开启声音
        id openSound = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@/%@",[[AccountCenter defaultCenter] loginAccountID],@"config/isOpenSound"]];
        self.isOpenSound     = openSound ? [openSound boolValue]:YES;
        // 开启震动
        id openVibrate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@/%@",[[AccountCenter defaultCenter] loginAccountID],@"config/isOpenVibrate"]];
        self.isOpenVibrate = openVibrate ? [openVibrate boolValue]:YES;
        
    }
    return self;
}

- (void)setIsFirstStartup:(BOOL)isFirstStartup
{
    _isFirstStartup = isFirstStartup;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isFirstStartup] forKey:@"config/isFirstStartup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsOpenSound:(BOOL)isOpenSound
{
    _isOpenSound = isOpenSound;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isOpenSound] forKey:[NSString stringWithFormat:@"%@/%@",[[AccountCenter defaultCenter] loginAccountID],@"config/isOpenSound"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsOpenVibrate:(BOOL)isOpenVibrate
{
    _isOpenVibrate = isOpenVibrate;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isOpenVibrate] forKey:[NSString stringWithFormat:@"%@/%@",[[AccountCenter defaultCenter] loginAccountID],@"config/isOpenVibrate"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}






















#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.isFirstStartup       = [aDecoder decodeBoolForKey:@"isFirst"];
        self.isOpenSound          = [aDecoder decodeBoolForKey:@"isSound"];
        self.isOpenVibrate        = [aDecoder decodeBoolForKey:@"isVibrate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_isFirstStartup forKey:@"isFirst"];
    [aCoder encodeBool:_isOpenSound    forKey:@"isSound"];
    [aCoder encodeBool:_isOpenVibrate  forKey:@"isVibrate"];

}

@end
