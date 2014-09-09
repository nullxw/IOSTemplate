//
//  UITabBarItem+SFCategory.m
//  ShadowFiend
//
//  Created by tixa on 14-8-20.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UITabBarItem+SFCategory.h"

@implementation UITabBarItem (SFCategory)

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        UIImage *select = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:select];
        tabBarItem.tag = tag;
        return tabBarItem;
    } else {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:nil tag:tag];
        [tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:image];
        return tabBarItem;
    }
}

@end
