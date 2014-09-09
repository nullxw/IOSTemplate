//
//  UIView+SFAutoLayout.m
//  ShadowFiend
//
//  Created by tixa on 14-7-11.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "UIView+SFAutoLayout.h"

@implementation UIView (SFAutoLayout)



#pragma mark - 生成并添加基本约束条件

// 关闭AutoresizingMask转换,添加视图,添加约束条件,设置约束条件优先级并返回约束条件
- (NSLayoutConstraint *)addConstraintWithItem:(id)firstItem
                                    attribute:(NSLayoutAttribute)firstAttribute
                                    relatedBy:(NSLayoutRelation)relation
                                       toItem:(id)secondItem
                                    attribute:(NSLayoutAttribute)secondAttribute
                                   multiplier:(CGFloat)multiplier
                                     constant:(CGFloat)constant
                                     priority:(UILayoutPriority)priority
{
    // 关闭AutoresizingMask转换
    if (firstItem != self) {
        [firstItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    if (secondItem != self) {
        [secondItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    if ((firstItem == self && secondItem == nil) || (firstItem == nil && secondItem == self)) { // 如果设置自身固定宽或高
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    // 添加子视图
    if (![firstItem superview] && firstItem != self) {
        [self addSubview:firstItem];
    }
    if (![secondItem superview] && secondItem != self) {
        [self addSubview:secondItem];
    }
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                  attribute:firstAttribute
                                                                  relatedBy:relation
                                                                     toItem:secondItem
                                                                  attribute:secondAttribute
                                                                 multiplier:multiplier
                                                                   constant:constant];
    constraint.priority = priority;
    [self addConstraint:constraint];
    
    return constraint;
}


// 关闭AutoresizingMask转换,添加视图,添加约束条件,设置约束条件优先级为UILayoutPriorityRequired并返回约束条件
- (NSLayoutConstraint *)addConstraintWithItem:(id)firstItem
                                    attribute:(NSLayoutAttribute)firstAttribute
                                    relatedBy:(NSLayoutRelation)relation
                                       toItem:(id)secondItem
                                    attribute:(NSLayoutAttribute)secondAttribute
                                   multiplier:(CGFloat)multiplier
                                     constant:(CGFloat)constant
{
    return [self addConstraintWithItem:firstItem
                             attribute:firstAttribute
                             relatedBy:relation
                                toItem:secondItem
                             attribute:secondAttribute
                            multiplier:multiplier
                              constant:constant
                              priority:UILayoutPriorityRequired];
}



#pragma mark - Base Wrap

// 添加固定比例约束条件
- (NSLayoutConstraint *)addMultiplierConstraintWithItem:(id)firstItem
                                              attribute:(NSLayoutAttribute)firstAttribute
                                           relativeItem:(id)secondItem
                                              attribute:(NSLayoutAttribute)secondAttribute
                                             multiplier:(CGFloat)multiplier
{
    return [self addConstraintWithItem:firstItem
                             attribute:firstAttribute
                             relatedBy:NSLayoutRelationEqual
                                toItem:secondItem ? secondItem : self
                             attribute:secondAttribute
                            multiplier:multiplier
                              constant:0.0
                              priority:UILayoutPriorityRequired];
}


// 添加固定常量约束条件
- (NSLayoutConstraint *)addConstantConstraintWithItem:(id)firstItem
                                            attribute:(NSLayoutAttribute)firstAttribute
                                         relativeItem:(id)secondItem
                                            attribute:(NSLayoutAttribute)secondAttribute
                                             constant:(CGFloat)constant
{
    return [self addConstraintWithItem:firstItem
                             attribute:firstAttribute
                             relatedBy:NSLayoutRelationEqual
                                toItem:secondItem ? secondItem : self
                             attribute:secondAttribute
                            multiplier:1.0
                              constant:constant
                              priority:UILayoutPriorityRequired];
}


// 添加固定常量约束条件
- (NSLayoutConstraint *)addConstantConstraintWithItem:(id)firstItem
                                            attribute:(NSLayoutAttribute)firstAttribute
                                             constant:(CGFloat)constant
{
    return [self addConstraintWithItem:firstItem
                             attribute:firstAttribute
                             relatedBy:NSLayoutRelationEqual
                                toItem:nil
                             attribute:NSLayoutAttributeNotAnAttribute
                            multiplier:1.0
                              constant:constant
                              priority:UILayoutPriorityRequired];
}


#pragma mark - Equation Custom

// 添加外边距约束条件
- (void)addMarginConstraintsWithItem:(id)firstItem
                        relativeItem:(id)secondItem
                              margin:(UIEdgeInsets)margin
{
    for (int i = 0; i < 4; i++) {
        float constant = 0.0;
        NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
        
        if (i == 0) {
            constant = margin.top;
            attribute = NSLayoutAttributeTop;
        } else if (i == 1) {
            constant = margin.left;
            attribute = NSLayoutAttributeLeft;
        } else if (i == 2) {
            constant = -margin.bottom;
            attribute = NSLayoutAttributeBottom;
        } else {
            constant = -margin.right;
            attribute = NSLayoutAttributeRight;
        }
        
        if (constant != kConstantNone && constant != -kConstantNone) {
            [self addConstantConstraintWithItem:firstItem
                                      attribute:attribute
                                   relativeItem:secondItem
                                      attribute:attribute
                                       constant:constant];
        }
    }
}


// 添加中心点约束条件
- (void)addCenterConstraintsWithItem:(id)firstItem
                        relativeItem:(id)secondItem
                              offset:(CGPoint)offset
{
    if (offset.x != kConstantNone) {
        [self addConstantConstraintWithItem:firstItem
                                  attribute:NSLayoutAttributeCenterX
                               relativeItem:secondItem
                                  attribute:NSLayoutAttributeCenterX
                                   constant:offset.x];
    }
    
    if (offset.y != kConstantNone) {
        [self addConstantConstraintWithItem:firstItem
                                  attribute:NSLayoutAttributeCenterY
                               relativeItem:secondItem
                                  attribute:NSLayoutAttributeCenterY
                                   constant:offset.y];
    }
}


// 添加大小约束条件
- (void)addSizeConstraintsWithItem:(id)firstItem size:(CGSize)size
{
    if (size.width != kConstantNone && size.width >= 0.0) {
        [self addConstraintWithItem:firstItem
                          attribute:NSLayoutAttributeWidth
                          relatedBy:NSLayoutRelationEqual
                             toItem:nil
                          attribute:NSLayoutAttributeNotAnAttribute
                         multiplier:1.0
                           constant:size.width
                           priority:UILayoutPriorityRequired];
    }
    
    if (size.height != kConstantNone && size.height >= 0.0) {
        [self addConstraintWithItem:firstItem
                          attribute:NSLayoutAttributeHeight
                          relatedBy:NSLayoutRelationEqual
                             toItem:nil
                          attribute:NSLayoutAttributeNotAnAttribute
                         multiplier:1.0
                           constant:size.height
                           priority:UILayoutPriorityRequired];
    }
}



#pragma mark - 生成并添加约束条件数组,由可视化语言

// 添加约束条件(可视化语言)
- (NSArray *)addConstraintsWithVisualFormat:(NSString *)format
                                    options:(NSLayoutFormatOptions)options
                                    metrics:(NSDictionary *)metrics
                                      views:(NSDictionary *)views
{
    // 关闭AutoresizingMask转换,添加子视图
    for (UIView *view in views.allValues) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (!view.superview && view != self) {
            [self addSubview:view];
        }
    }
    
    //解析标准可视化语言
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                   options:options
                                                                   metrics:metrics
                                                                     views:views];
    [self addConstraints:constraints];
    
    return constraints;
}



#pragma mark - RemoveAllConstraints

// 移除所有约束条件
- (void)removeAllConstraints
{
    [self removeConstraints:self.constraints];
}


@end

