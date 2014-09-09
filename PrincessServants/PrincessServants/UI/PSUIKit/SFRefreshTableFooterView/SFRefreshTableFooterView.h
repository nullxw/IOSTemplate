//
//  SFRefreshTableFooterView.h
//  SFExpress
//
//  Created by tixa on 14-1-7.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SFPullRefreshStatePulling = 0,
	SFPullRefreshStateNormal,
	SFPullRefreshStateLoading,
} SFPullRefreshState;

typedef enum {
	SFPullRefreshStyleBlack = 0,
	SFPullRefreshStyleWhite
} SFPullRefreshStyle;

@protocol SFRefreshTableFooterDelegate;

@interface SFRefreshTableFooterView : UIView

@property (nonatomic, assign) id <SFRefreshTableFooterDelegate> delegate;
@property (nonatomic, assign) SFPullRefreshStyle style;
@property (nonatomic, assign) SFPullRefreshState state;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

- (void)sfRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)sfRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)sfRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol SFRefreshTableFooterDelegate <NSObject>

- (void)sfRefreshTableFooterDidTriggerRefresh:(SFRefreshTableFooterView *)view;
- (BOOL)sfRefreshTableFooterDataSourceIsLoading:(SFRefreshTableFooterView *)view;

@end
