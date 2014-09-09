//
//  UITabBarItem+SFCategory.h
//  ShadowFiend
//
//  Created by tixa on 14-8-20.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (SFCategory)

+ (instancetype)itemWithTitle:(NSString *)title
                        image:(UIImage *)image
                selectedImage:(UIImage *)selectedImage
                          tag:(NSInteger)tag;

@end
