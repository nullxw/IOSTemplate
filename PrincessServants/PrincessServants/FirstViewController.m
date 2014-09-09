//
//  FirstViewController.m
//  ShadowFiend
//
//  Created by tixa on 14-8-20.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "FirstViewController.h"
#import "ForthViewController.h"
#import "FifthViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.showNavigationBar = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"附近";
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 100.0, 100, 30)];
//    view.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:view];
    self.view.backgroundColor = [UIColor greenColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 100.0, 100, 30)];
    [button setTitle:@"dd" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
//    [self showLoadingViewWithTitle:@"正在加载。。。"];
//    [self showLoadingView];
    
}

- (void)dd
{
    self.hidesBottomBarWhenPushed = YES;
    FifthViewController *forth = [[FifthViewController alloc] init];
    [self.navigationController pushViewController:forth animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
