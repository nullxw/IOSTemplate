//
//  UIView+SFAutoLayout.h
//  ShadowFiend
//
//  Created by tixa on 14-7-11.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kConstantNone 99999.0

@interface UIView (SFAutoLayout)

// 关闭AutoresizingMask转换,添加视图,添加约束条件,设置约束条件优先级并返回约束条件
- (NSLayoutConstraint *)addConstraintWithItem:(id)firstItem
                                    attribute:(NSLayoutAttribute)firstAttribute
                                    relatedBy:(NSLayoutRelation)relation
                                       toItem:(id)secondItem
                                    attribute:(NSLayoutAttribute)secondAttribute
                                   multiplier:(CGFloat)multiplier
                                     constant:(CGFloat)constant
                                     priority:(UILayoutPriority)priority;


// 关闭AutoresizingMask转换,添加视图,添加约束条件,设置约束条件优先级为UILayoutPriorityRequired并返回约束条件
- (NSLayoutConstraint *)addConstraintWithItem:(id)firstItem
                                    attribute:(NSLayoutAttribute)firstAttribute
                                    relatedBy:(NSLayoutRelation)relation
                                       toItem:(id)secondItem
                                    attribute:(NSLayoutAttribute)secondAttribute
                                   multiplier:(CGFloat)multiplier
                                     constant:(CGFloat)constant;


// 添加固定比例约束条件
- (NSLayoutConstraint *)addMultiplierConstraintWithItem:(id)firstItem
                                              attribute:(NSLayoutAttribute)firstAttribute
                                           relativeItem:(id)secondItem
                                              attribute:(NSLayoutAttribute)secondAttribute
                                             multiplier:(CGFloat)multiplier;


// 添加固定常量约束条件(第二个item存在)
- (NSLayoutConstraint *)addConstantConstraintWithItem:(id)firstItem
                                            attribute:(NSLayoutAttribute)firstAttribute
                                         relativeItem:(id)secondItem
                                            attribute:(NSLayoutAttribute)secondAttribute
                                             constant:(CGFloat)constant;


// 添加固定常量约束条件(第二个item不存在)
- (NSLayoutConstraint *)addConstantConstraintWithItem:(id)firstItem
                                            attribute:(NSLayoutAttribute)firstAttribute
                                             constant:(CGFloat)constant;


// 添加外边距约束条件
- (void)addMarginConstraintsWithItem:(id)firstItem
                        relativeItem:(id)secondItem
                              margin:(UIEdgeInsets)margin;


// 添加中心点约束条件
- (void)addCenterConstraintsWithItem:(id)firstItem
                        relativeItem:(id)secondItem
                              offset:(CGPoint)offset;


// 添加大小约束条件
- (void)addSizeConstraintsWithItem:(id)firstItem size:(CGSize)size;


// 添加约束条件(可视化语言)
- (NSArray *)addConstraintsWithVisualFormat:(NSString *)format
                                    options:(NSLayoutFormatOptions)options
                                    metrics:(NSDictionary *)metrics
                                      views:(NSDictionary *)views;


// 移除所有约束条件
- (void)removeAllConstraints;

@end

