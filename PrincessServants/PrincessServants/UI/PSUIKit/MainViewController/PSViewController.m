//
//  PSViewController.m
//  PrincessServants
//
//  Created by tixa on 14-9-4.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "PSViewController.h"
#import "ImageCache.h"

@interface PSViewController ()

@property (nonatomic, strong) UIView                      *loadingView;            // 加载视图
@property (nonatomic, strong) UIActivityIndicatorView     *activityIndicatorView;
@property (nonatomic, strong) UILabel                     *loadingTitleLabel;

@end

@implementation PSViewController

@synthesize tag = _tag;
@synthesize systemVersion = _systemVersion;
@synthesize navigationBar = _navigationBar;
@synthesize backgroundColor = _backgroundColor;
@synthesize showNavigationBar = _showNavigationBar;
@synthesize showBackBarButtonItem = _showBackBarButtonItem;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        _systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (_systemVersion>=7.0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            //            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _backgroundColor = [UIColor whiteColor];
        _showNavigationBar = NO;
        _showBackBarButtonItem = NO;
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
//    NSLog(@"%s:", __FUNCTION__);
    
    [self setupSubviews];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSLog(@"%s:", __FUNCTION__);
    
    self.view.backgroundColor = _backgroundColor;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSLog(@"%s:", __FUNCTION__);
    
    if (_navigationBar) {
        [self.view bringSubviewToFront:_navigationBar];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSLog(@"%s:", __FUNCTION__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    NSLog(@"%s:", __FUNCTION__);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    NSLog(@"%s:", __FUNCTION__);
    
}

- (void)dealloc
{
    [self willDealloc];
}

// 释放前的清除操作
- (void)willDealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self hideLoadingView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[ImageCache sharedCache] clearCache];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Subviews

// 加载子视图,修改父类子视图
- (void)setupSubviews
{
    // 导航栏
    if (_showNavigationBar) { // 显示自定义的导航栏
        CGFloat height = (_systemVersion >= 7.0) ? 64.0 : 44.0;  //导航栏高度
        CGFloat y = (_systemVersion >= 7.0) ? 0.0 : 20.0;
        _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, y, self.view.frame.size.width, height)];
        _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _navigationBar.topItem.title = self.title;
        [self.view addSubview:_navigationBar];
    }
    // 返回按钮
    if (_showBackBarButtonItem) {
        
        if (_navigationBar) {
            _navigationBar.topItem.backBarButtonItem = self.defaultBackBarButtonItem;
        }else{
            self.navigationItem.backBarButtonItem = self.defaultBackBarButtonItem;
        }
        
    }else{
        
        if (_navigationBar) {
            _navigationBar.topItem.hidesBackButton = YES;
        }else{
            self.navigationItem.hidesBackButton = YES;
        }
        [self setLeftBarButtonItems:nil];
    }
    
}

#pragma mark - NavigationBar Methods

// 设置导航栏左侧按钮
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
{
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = leftBarButtonItems;
    } else if (self.navigationBar) {
        self.navigationBar.topItem.leftBarButtonItems = leftBarButtonItems;
    }
}

// 设置导航栏右侧按钮
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    } else if (self.navigationBar) {
        self.navigationBar.topItem.rightBarButtonItems = rightBarButtonItems;
    }
}


#pragma mark - Loading View

// 显示加载视图
- (void)showLoadingView
{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
        if (_systemVersion >= 7.0) {
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y-80.0);
        }else{
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y-50.0);
        }
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        backgroundView.layer.cornerRadius = 6.0;
        [_loadingView addSubview:backgroundView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = backgroundView.center;
        [_loadingView addSubview:_activityIndicatorView];
        
        [self.view addSubview:_loadingView];
    }
    
    [_loadingTitleLabel removeFromSuperview];
    [self.view bringSubviewToFront:_loadingView];
    _loadingView.hidden = NO;
    
    if (_navigationBar) {
        [self.view bringSubviewToFront:_navigationBar];
    }
    
    [_activityIndicatorView startAnimating];
    
}

- (void)showLoadingViewWithTitle:(NSString *)title
{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        _loadingView.backgroundColor = [UIColor greenColor];
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
        if (_systemVersion >= 7.0) {
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y-80.0);
        }else{
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y-50.0);
        }
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        backgroundView.layer.cornerRadius = 6.0;
        [_loadingView addSubview:backgroundView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = CGPointMake(CGRectGetMidX(backgroundView.frame), CGRectGetMidY(backgroundView.frame)-10.0);
        [_loadingView addSubview:_activityIndicatorView];
        
        _loadingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, backgroundView.frame.size.width, 40.0)];
        _loadingTitleLabel.center = CGPointMake(CGRectGetMidX(backgroundView.frame), CGRectGetMidY(backgroundView.frame)+30.0);
        _loadingTitleLabel.backgroundColor = [UIColor clearColor];
        _loadingTitleLabel.textAlignment = NSTextAlignmentCenter;
        _loadingTitleLabel.font = [UIFont systemFontOfSize:12.0];
        _loadingTitleLabel.textColor = [UIColor whiteColor];
        _loadingTitleLabel.text = title;
        
        [self.view addSubview:_loadingView];
    }
    
    [_loadingView addSubview:_loadingTitleLabel];
    [self.view bringSubviewToFront:_loadingView];
    _loadingView.hidden = NO;
    _loadingTitleLabel.text = title;
    if (_navigationBar) {
        [self.view bringSubviewToFront:_navigationBar];
    }
    
    [_activityIndicatorView startAnimating];
}

// 隐藏加载视图
- (void)hideLoadingView
{
    _loadingView.hidden = YES;
    [_activityIndicatorView stopAnimating];
}

#pragma mark - Properties

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    if (_navigationBar) {
        _navigationBar.topItem.title = title;
    }
}

#pragma mark - Default View Style

// 默认返回按钮样式(dismiss或pop)
- (UIBarButtonItem *)defaultBackBarButtonItem
{
    if (self.navigationController.viewControllers.count > 1) {
        return [self defaultBackBarButtonItemWithTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    } else {
        return [self defaultBackBarButtonItemWithTarget:self action:@selector(dismissViewControllerAnimated:completion:)];
    }
}

// 默认返回按钮样式
- (UIBarButtonItem *)defaultBackBarButtonItemWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [[UIImage imageNamed:@"sf_navibar_back_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 5.0) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:target
                                                                     action:action];
    return barButtonItem;
}


@end
