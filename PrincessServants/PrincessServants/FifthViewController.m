//
//  FifthViewController.m
//  PrincessServants
//
//  Created by tixa on 14-9-5.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "FifthViewController.h"

@interface FifthViewController ()

@end

@implementation FifthViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.showSearchBar = YES;
        self.showRefreshHeaderView = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"第五个";
    self.dataArray.array = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    [self reloadTable];
    
    [self autoTriggerHeaderRefresh:YES];
    [self performSelector:@selector(tableViewDidFinishHeaderRefreshReload:) withObject:nil afterDelay:5];
}

- (void)tableViewDidTriggerHeaderRefresh
{
//    [self showLoadingViewWithTitle:@"dddd"];
    [self showLoadingView];

}


// 搜索文本变化
- (void)searchTextDidChange:(NSString *)searchText
{
    // NSLog(@"searchTextDidChange:");
    
}


// 搜索开始
- (void)searchDidBegin:(UISearchBar *)searchView
{
    //NSLog(@"searchDidBegin:");
    
}
// 搜索结束
- (void)searchDidEnd:(UISearchBar *)searchView
{
    //NSLog(@"searchDidEnd:");
    
}
// 搜索按钮点击
- (void)searchDidConfirm:(UISearchBar *)searchView
{
    //NSLog(@"searchDidConfirm:");
    
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
