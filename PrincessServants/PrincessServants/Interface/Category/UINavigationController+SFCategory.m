//
//  UINavigationController+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-6-24.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UINavigationController+SFCategory.h"

@implementation UINavigationController (SFCategory)

- (void)pushViewControllerWithClassName:(NSString *)className
{
    Class class = NSClassFromString(className);
    UIViewController *viewController = [[class alloc] init];
    [self pushViewController:viewController animated:YES];
}

@end
