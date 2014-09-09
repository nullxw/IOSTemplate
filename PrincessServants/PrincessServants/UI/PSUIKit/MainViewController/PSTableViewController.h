//
//  PSTableViewController.h
//  PrincessServants
//
//  Created by tixa on 14-9-4.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCategory.h"
#import "EGORefreshTableHeaderView.h"
#import "SFRefreshTableFooterView.h"

@interface PSTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate, EGORefreshTableHeaderDelegate, SFRefreshTableFooterDelegate>

// 数据
@property (nonatomic, strong) NSMutableArray        *dataArray;         // 数组形式数据源


// 视图
@property (nonatomic, strong) UIColor                         *tableViewCellSeparatorColor;
@property (nonatomic)         UITableViewCellSeparatorStyle    tableViewCellSeparatorStyle;
@property (nonatomic, strong) EGORefreshTableHeaderView       *refreshHeaderView;
@property (nonatomic, strong) SFRefreshTableFooterView        *refreshFooterView;

// 搜索
@property (nonatomic)               BOOL         showSearchBar;                 //是否显示搜索栏
@property (nonatomic, readonly)     UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, readonly)     NSMutableArray *searchResultsArray;         // 数组形式搜索结果

// 标记
@property (nonatomic)               BOOL         enableTableViewCellLongPress;  // 添加表元长按监听      长按对mySearchDisplayController中的搜索tableview无效
@property (nonatomic)               BOOL         showRefreshHeaderView;         // 是否支持下拉刷新   默认NO
@property (nonatomic)               BOOL         showRefreshFooterView;         // 是否支持上拉加载   默认NO
@property (nonatomic)               BOOL         showTableBlankView;            // 是否显示默认空数据视图

@property (nonatomic, readonly)     CGFloat      systemVersion;                 // 当前iOS SDK版本信息


// 设置可复用cell
- (void)tableView:(UITableView *)tableView setupCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
// cell长按事件  长按对mySearchDisplayController中的搜索tableview无效
- (void)tableView:(UITableView *)tableView didLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)reloadTable;
// 释放前的清除操作
- (void)willDealloc;
// 显示加载视图
- (void)showLoadingView;
- (void)showLoadingViewWithTitle:(NSString *)title;
// 隐藏加载视图
- (void)hideLoadingView;

// 设置导航栏左侧按钮
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems;
// 设置导航栏右侧按钮
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems;

// 默认返回按钮样式(dismiss或pop)
- (UIBarButtonItem *)defaultBackBarButtonItem;
// 默认返回按钮样式
- (UIBarButtonItem *)defaultBackBarButtonItemWithTarget:(id)target action:(SEL)action;


// 下拉刷新触发调用事件
- (void)tableViewDidTriggerHeaderRefresh;
// 下拉刷新回调  reload参数:是否触发reloadTable函数
- (void)tableViewDidFinishHeaderRefreshReload:(BOOL)reload;
// 自动下拉更新  animated:是否显示刷新动画效果
- (void)autoTriggerHeaderRefresh:(BOOL)animated;


// 上拉加载事件
- (void)tableViewDidTriggerFooterRefresh;
// 上拉加载回调
- (void)tableViewDidFinishFooterRefreshReload:(BOOL)reload;


// 显示刷新提示信息，持续指定duration
- (void)showRefreshLabel:(NSString *)message duration:(NSTimeInterval)duration;
// 显示刷新提示标签，持续默认duration
- (void)showRefreshLabel:(NSString *)message;


- (void)searchTextDidChange:(NSString *)searchText;
- (void)searchDidBegin:(UISearchBar *)searchView;
- (void)searchDidEnd:(UISearchBar *)searchView;
- (void)searchDidConfirm:(UISearchBar *)searchView;

@end
