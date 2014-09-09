//
//  PSTabBarViewController.m
//  PrincessServants
//
//  Created by tixa on 14-9-4.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "PSTabBarViewController.h"
#import "NearViewController.h"
#import "ChatViewController.h"
#import "PersonalViewController.h"


@interface PSTabBarViewController ()<UITabBarControllerDelegate>
{
    NearViewController      *nearViewController;
    ChatViewController      *chatViewController;
    PersonalViewController  *personalViewController;
    
}

@end

@implementation PSTabBarViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        nearViewController = [[NearViewController alloc]init];
        UINavigationController *nearNav = [[UINavigationController alloc] initWithRootViewController:nearViewController];
        nearNav.tabBarItem = [UITabBarItem itemWithTitle:@"附近" image:[UIImage imageNamed:@"sf_tabbar_0_sel"] selectedImage:[UIImage imageNamed:@"sf_tabbar_0"] tag:0];
        
        chatViewController = [[ChatViewController alloc]init];
        UINavigationController *chatNav = [[UINavigationController alloc] initWithRootViewController:chatViewController];
        chatNav.tabBarItem = [UITabBarItem itemWithTitle:@"聊天" image:[UIImage imageNamed:@"sf_tabbar_1_sel"] selectedImage:[UIImage imageNamed:@"sf_tabbar_1"] tag:1];
        
        personalViewController = [[PersonalViewController alloc]init];
        UINavigationController *personalNav = [[UINavigationController alloc] initWithRootViewController:personalViewController];
        personalNav.tabBarItem = [UITabBarItem itemWithTitle:@"我的" image:[UIImage imageNamed:@"sf_tabbar_2_sel"] selectedImage:[UIImage imageNamed:@"sf_tabbar_2"] tag:2];
        
        [self setViewControllers:@[nearNav, chatNav, personalNav] animated:YES];
        self.delegate = self;
        self.selectedIndex = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers
{
    
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    
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
