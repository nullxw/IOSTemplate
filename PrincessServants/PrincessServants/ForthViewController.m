//
//  ForthViewController.m
//  ShadowFiend
//
//  Created by tixa on 14-8-20.
//  Copyright (c) 2014年 SONGQG. All rights reserved.
//

#import "ForthViewController.h"
#import "ThirdViewController.h"

@interface ForthViewController ()

@end

@implementation ForthViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.showBackBarButtonItem = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"第四个";
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0.0, 100, 30)];
    [button setTitle:@"dd" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor grayColor]];
    [button addTarget:self action:@selector(dd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self showLoadingViewWithTitle:@"正在加载。。。"];
}

- (void)dd
{
    
    self.hidesBottomBarWhenPushed = YES;
    ThirdViewController *forth = [[ThirdViewController alloc] init];
    [self.navigationController pushViewController:forth animated:YES];
//    self.hidesBottomBarWhenPushed = NO;
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
