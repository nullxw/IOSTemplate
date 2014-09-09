//
//  SFRefreshTableFooterView.m
//  SFExpress
//
//  Created by tixa on 14-1-7.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "SFRefreshTableFooterView.h"
#import "ViewCenter.h"

@interface SFRefreshTableFooterView ()
{
    UIScrollView *_scrollView;
}
@end

@implementation SFRefreshTableFooterView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
		
		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 8.0, frame.size.width, 20.0)];
		_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
		_statusLabel.textColor = [UIColor blackColor];
		_statusLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		_statusLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_statusLabel];
        
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityView.frame = CGRectMake(frame.size.width / 2.0 - 90.0, 10.0, 20.0, 20.0);
		[self addSubview:_activityView];
		
        [self setState:SFPullRefreshStateNormal];
    }
    return self;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)layoutSubviews
{
    if (!_scrollView && [self.superview isKindOfClass:[UIScrollView class]]) {
        _scrollView = (UIScrollView *)self.superview;
        
        CGRect frame = self.frame;
        frame.origin.y = (_scrollView.contentSize.height < _scrollView.frame.size.height) ? _scrollView.frame.size.height * 2.0 : _scrollView.contentSize.height;
        self.frame = frame;
        
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
}



#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize contentSize = [[change valueForKey:@"new"] CGSizeValue];
        
        CGRect frame = self.frame;
        frame.origin.y = (contentSize.height < _scrollView.frame.size.height) ? _scrollView.frame.size.height * 2.0 : _scrollView.contentSize.height;
        self.frame = frame;
    }
}



#pragma mark - Properties

/*设置状态*/
- (void)setState:(SFPullRefreshState)state
{
    _state = state;
    
	switch (state) {
		case SFPullRefreshStatePulling:
			_statusLabel.text = NSLocalizedString(@"松开确认更新", @"Release to refresh status");
			break;
            
		case SFPullRefreshStateNormal:
			_statusLabel.text = NSLocalizedString(@"上拉获取更多", @"Pull up to refresh status");
			[_activityView stopAnimating];
			break;
            
		case SFPullRefreshStateLoading:
			_statusLabel.text = NSLocalizedString(@"正在加载,请稍候", @"Loading Status");
			[_activityView startAnimating];
			break;
            
		default:
			break;
	}
}

/*设置风格*/
- (void)setStyle:(SFPullRefreshStyle)style
{
    _style = style;
    
    switch (style) {
        case SFPullRefreshStyleBlack:
            _statusLabel.textColor = [UIColor blackColor];
            _statusLabel.shadowColor = [UIColor colorWithWhite:0.9 alpha:1.0];
            _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            break;
            
        case SFPullRefreshStyleWhite:
            _statusLabel.textColor = [UIColor whiteColor];
            _statusLabel.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0];
            _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            break;
            
        default:
            break;
    }
}



#pragma mark - ScrollView Methods

/*视图滚动事件*/
- (void)sfRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
	//分“超界上拉”、“界内上拉”、“无上拉”三种情况讨论
	if (_state == SFPullRefreshStateLoading) {//状态为加载时，上述三种情况分别设底部inset为40、offset、0
		CGFloat offset = MAX(scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height, 0);
		offset = MIN(offset, 40);
        
		UIEdgeInsets contentInset = scrollView.contentInset;
		contentInset.bottom = offset;
		scrollView.contentInset = contentInset;
	}  else if (scrollView.isDragging) {//正在拖拽时
		//检测是否delegate已在加载状态
		BOOL isLoading = NO;
		if ([_delegate respondsToSelector:@selector(sfRefreshTableFooterDataSourceIsLoading:)]) {
			isLoading = [_delegate sfRefreshTableFooterDataSourceIsLoading:self];
		}
		
		//获取拖拽的幅度，更新状态信息
		CGFloat dragOffset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
		if (!isLoading && _state == SFPullRefreshStatePulling && dragOffset < 45.0 && dragOffset > 0.0 && scrollView.contentSize.height >= scrollView.frame.size.height) {
			[self setState:SFPullRefreshStateNormal];
		} else if (!isLoading && _state == SFPullRefreshStateNormal && dragOffset > 45.0 && scrollView.contentSize.height >= scrollView.frame.size.height) {
			[self setState:SFPullRefreshStatePulling];
		}
		
		//非加载状态时，底部inset清零
		if (scrollView.contentInset.bottom) {
			UIEdgeInsets contentInset = scrollView.contentInset;
			contentInset.bottom = 0.0;
			scrollView.contentInset = contentInset;
		}
	}
}

/*结束拖拽动作*/
- (void)sfRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
	//检测是否delegate已在加载状态
	BOOL isLoading = NO;
	if ([_delegate respondsToSelector:@selector(sfRefreshTableFooterDataSourceIsLoading:)]) {
		isLoading = [_delegate sfRefreshTableFooterDataSourceIsLoading:self];
	}
	
	//delegate不处于加载状态，且拖拽幅度超过设定值，触发更新事件
	CGFloat dragOffset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
	if (!isLoading && dragOffset >= 45.0 && scrollView.contentSize.height >= scrollView.frame.size.height) {
		if ([_delegate respondsToSelector:@selector(sfRefreshTableFooterDidTriggerRefresh:)]) {
			[_delegate sfRefreshTableFooterDidTriggerRefresh:self];
		}
		
		//底部inset固定40
        [UIView animateWithDuration:0.3 animations:^{
            UIEdgeInsets contentInset = scrollView.contentInset;
            contentInset.bottom = 40.0;
            scrollView.contentInset = contentInset;
        }];
		
		[self setState:SFPullRefreshStateLoading];
	}
}

/*完成加载任务*/
- (void)sfRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
	//底部inset清零
    [UIView animateWithDuration:0.3 animations:^{
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.bottom = 0.0;
        scrollView.contentInset = contentInset;
    }];
	
	[self setState:SFPullRefreshStateNormal];
}

@end
