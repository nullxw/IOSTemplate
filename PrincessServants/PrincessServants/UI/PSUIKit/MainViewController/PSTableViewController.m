//
//  PSTableViewController.m
//  PrincessServants
//
//  Created by tixa on 14-9-4.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "PSTableViewController.h"

#define REFRESH_LABEL_DURATION 2.0

@interface PSTableViewController ()
{
    UILabel     *_refreshLabel;          // 刷新提示信息标签
    UIImageView *_blankView;             // 空白页面
    UIView      *_tempTableFooterView;   //被_blankView替换前的tableFooterView
    
    NSString    *_cellIdentifier;
    
    BOOL _isHeaderReloading;             // 是否正在下拉刷新
    BOOL _isFooterReloading;             // 是否正在上拉加载
}

@property (nonatomic, strong) UIView                      *loadingView;            // 加载视图
@property (nonatomic, strong) UIActivityIndicatorView     *activityIndicatorView;
@property (nonatomic, strong) UILabel                     *loadingTitleLabel;

@property (nonatomic, strong)       UISearchBar    *searchBar;

@end

@implementation PSTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (_systemVersion>=7.0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _enableTableViewCellLongPress = NO;
        _showRefreshHeaderView = NO;
        _showRefreshFooterView = NO;
        _showTableBlankView = NO;
        
        _cellIdentifier = NSStringFromClass(self.class);
        _tableViewCellSeparatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableViewCellSeparatorColor = [UIColor grayColor];
        
        
        _dataArray = [NSMutableArray array];
        _searchResultsArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // tableView的一些自定义
    self.tableView.separatorColor = _tableViewCellSeparatorColor;
    self.tableView.separatorStyle = _tableViewCellSeparatorStyle;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)]; // 底部截止线
    _tempTableFooterView = self.tableView.tableFooterView;
    
    //初始化下拉更新功能
	if (_showRefreshHeaderView && !_refreshHeaderView) {
        CGRect frame = self.tableView.frame;
        frame.origin.x = 0.0;
        frame.origin.y = -frame.size.height;
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:frame];
		_refreshHeaderView.delegate = self;
//		[self.tableView addSubview:_refreshHeaderView];
        [_refreshHeaderView refreshLastUpdatedDate];
	}

    // 初始化上拉加载功能
	if (_showRefreshFooterView && !_refreshFooterView) {
        CGRect frame = self.tableView.frame;
        frame.origin.x = 0.0;
        frame.origin.y = frame.size.height * 2;//初始化不显示
        
		_refreshFooterView = [[SFRefreshTableFooterView alloc] initWithFrame:frame];
		_refreshFooterView.delegate = self;
	}
    [self reloadRefreshTableHeaderView];
    [self reloadRefreshTableFooterView];
    
    //搜索栏
    if ((_showSearchBar) && !_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"搜索", nil);
        _searchBar.barStyle = UIBarStyleDefault;
        _searchBar.keyboardType = UIKeyboardTypeDefault;
        self.tableView.tableHeaderView = _searchBar;  // 表头部显示搜索栏
        
        [self.tableView scrollRectToVisible:CGRectMake(0.0, self.tableView.tableHeaderView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];//默认隐藏搜索栏
        
        _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _mySearchDisplayController.delegate = self;
        _mySearchDisplayController.searchResultsDataSource = self;
        _mySearchDisplayController.searchResultsDelegate = self;
    }
    
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == _mySearchDisplayController.searchResultsTableView) { // 搜索
        return 1;
    }else{  // 正常
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == _mySearchDisplayController.searchResultsTableView) { // 搜索
        return self.searchResultsArray.count;
    }else{ // 正常
        return self.dataArray.count;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:_cellIdentifier];
        
        if (_enableTableViewCellLongPress && (tableView == self.tableView)) {//长按监听
            UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewCellLongPressAction:)];
            longPressGestureRecognizer.minimumPressDuration = 1.0;
            [cell addGestureRecognizer:longPressGestureRecognizer];
        }
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    cell.textLabel.text = @"";
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self tableView:tableView setupCell:cell atIndexPath:indexPath];
    
    return cell;
}

// 设置可复用cell
- (void)tableView:(UITableView *)tableView setupCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableViewCellLongPressAction:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)longPressGesture.view];
        [self tableView:self.tableView didLongPressRowAtIndexPath:indexPath];
    }
}

// cell长按事件
- (void)tableView:(UITableView *)tableView didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        id object;
        if (tableView == _mySearchDisplayController.searchResultsTableView) { // 搜索
            
            object = [self.searchResultsArray objectAtIndex:indexPath.row];
            [self.searchResultsArray removeObject:object];
            
        } else {  // 正常
            object = [self.dataArray objectAtIndex:indexPath.row];
            [self.dataArray removeObject:object];
            
            if (!self.dataArray.count) { // 删除了最后一组
                if (self.showTableBlankView) {
                    [self reloadTableBlankView];
                }
                [self reloadRefreshTableFooterView];
            }
        }
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }   
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

// 刷新表视图、空数据提示视图、上拉加载视图
- (void)reloadTable
{
    [self.tableView reloadData];
    
    if (self.showTableBlankView) {
        [self reloadTableBlankView];
    }
    [self reloadRefreshTableFooterView];
}

// 刷新上拉加载视图
- (void)reloadRefreshTableFooterView
{
    if (_showRefreshFooterView) {
        if (!_dataArray.count) { // 空数据
            [_refreshFooterView removeFromSuperview];
        } else { // 有数据
            [self.tableView addSubview:_refreshFooterView];
        }
    } else { // 不显示
        [_refreshFooterView removeFromSuperview];
    }
}

// 刷新下拉刷新视图
- (void)reloadRefreshTableHeaderView
{
    if (_showRefreshHeaderView) {
        [self.tableView addSubview:_refreshHeaderView];
    } else { // 不显示
        [_refreshHeaderView removeFromSuperview];
    }
}

// 刷新无数据提示视图
- (void)reloadTableBlankView
{
    if (!_dataArray.count) { // 空数据
        if (!_blankView) {
            _blankView = [[UIImageView alloc] initWithFrame:CGRectZero];
            _blankView.contentMode = UIViewContentModeCenter;
        }
        
        _blankView.frame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 180.0);
        _blankView.image = _isHeaderReloading ? [UIImage imageNamed:@"table_blank_loading"] : [UIImage imageNamed:@"table_blank_normal"];
        
        if (self.tableView.tableFooterView != _blankView) {
            _tempTableFooterView = self.tableView.tableFooterView;
        }
        self.tableView.tableFooterView = _blankView;
    } else { // 有数据
        if (self.tableView.tableFooterView == _blankView) {
            self.tableView.tableFooterView = _tempTableFooterView;
        }
        
        [_blankView removeFromSuperview];
        _blankView = nil;
    }
}

#pragma mark - 下拉刷新  上拉加载

// 下拉刷新触发调用事件
- (void)tableViewDidTriggerHeaderRefresh
{
    if (self.showTableBlankView) {
        [self reloadTableBlankView];
    }
    
}

// 上拉加载事件
- (void)tableViewDidTriggerFooterRefresh
{
    
}

// 下拉刷新回调
- (void)tableViewDidFinishHeaderRefreshReload:(BOOL)reload
{
    _isHeaderReloading = NO;
	[_refreshHeaderView performSelectorOnMainThread:@selector(egoRefreshScrollViewDataSourceDidFinishedLoading:) withObject:self.tableView waitUntilDone:NO];
    
    // 回弹动画后移除控件
    if (!_showRefreshFooterView && _refreshFooterView) {
        [_refreshFooterView removeFromSuperview];
        _refreshFooterView.delegate = nil;
        _refreshFooterView = nil;
    }
    
    if (reload) {
        [self reloadTable];
    }else{
        if (self.showTableBlankView) {
            [self reloadTableBlankView];
        }
        [self reloadRefreshTableFooterView];
    }
}


// 上拉加载回调
- (void)tableViewDidFinishFooterRefreshReload:(BOOL)reload
{
    _isFooterReloading = NO;
    [_refreshFooterView performSelectorOnMainThread:@selector(sfRefreshScrollViewDataSourceDidFinishedLoading:) withObject:self.tableView waitUntilDone:NO];
    
    // 回弹动画后移除控件
    if (!_showRefreshFooterView && _refreshFooterView) {
        [_refreshFooterView removeFromSuperview];
        _refreshFooterView.delegate = nil;
        _refreshFooterView = nil;
    }
    
    if (reload) {
        [self reloadTable];
    }
}


// 自动下拉更新
- (void)autoTriggerHeaderRefresh:(BOOL)animated
{
    if (animated) {
        [self.tableView setContentOffset:CGPointMake(0.0, -65.0)];
        [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableView];
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
    } else {
        _isHeaderReloading = YES;
        [self tableViewDidTriggerHeaderRefresh];
    }
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.showRefreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    if (self.showRefreshFooterView) {
        [_refreshFooterView sfRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.showRefreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if (self.showRefreshFooterView) {
        [_refreshFooterView sfRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - Refresh Delegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
	_isHeaderReloading = YES;
    [self tableViewDidTriggerHeaderRefresh];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return _isHeaderReloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)sfRefreshTableFooterDidTriggerRefresh:(SFRefreshTableFooterView *)view
{
	_isFooterReloading = YES;
    [self tableViewDidTriggerFooterRefresh];
}

- (BOOL)sfRefreshTableFooterDataSourceIsLoading:(SFRefreshTableFooterView *)view
{
	return _isFooterReloading;
}


#pragma mark - Search Methods
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

#pragma mark - searchDisplayController Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
   [self searchTextDidChange:searchString];
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self searchDidBegin:controller.searchBar];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self searchDidEnd:controller.searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchDidConfirm:searchBar];
}

#pragma mark - Refresh Methods

// 显示刷新提示信息,持续指定duration
- (void)showRefreshLabel:(NSString *)message duration:(NSTimeInterval)duration
{
    if (!_refreshLabel) {
        _refreshLabel = [[UILabel alloc] init];
        _refreshLabel.alpha = 0.0;
        _refreshLabel.layer.cornerRadius = 6.0;
        _refreshLabel.backgroundColor = [UIColor blackTranslucentColor];
        _refreshLabel.textColor = [UIColor whiteColor];
        _refreshLabel.textAlignment = NSTextAlignmentCenter;
        _refreshLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [self.view addSubview:_refreshLabel];
    }
    _refreshLabel.frame = CGRectMake(self.tableView.frame.origin.x + 5.0, self.tableView.frame.origin.y + 4.0, self.tableView.frame.size.width - 10.0, 30.0);
    
    if (message.length) {
        _refreshLabel.text = message;
        
        [self showRefreshLabelAnimation];
        [self performSelector:@selector(hideRefreshLabelAnimation) withObject:nil afterDelay:duration];
    }
}

// 显示刷新提示标签,持续默认duration
- (void)showRefreshLabel:(NSString *)message
{
    [self showRefreshLabel:message duration:REFRESH_LABEL_DURATION];
}

// 刷新提示标签显示动画
- (void)showRefreshLabelAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        _refreshLabel.alpha = 1.0;
    }];
}

// 刷新提示标签隐藏动画
- (void)hideRefreshLabelAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        _refreshLabel.alpha = 0.0;
    }];
}

#pragma mark - NavigationBar Methods

// 设置导航栏左侧按钮
- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
{
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItems = leftBarButtonItems;
    }
}

// 设置导航栏右侧按钮
- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
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
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y+70.0);
        }else{
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y+90.0);
        }
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
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
    
    [_activityIndicatorView startAnimating];
    
}

- (void)showLoadingViewWithTitle:(NSString *)title
{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
        if (_systemVersion >= 7.0) {
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y+70.0);
        }else{
            backgroundView.center = CGPointMake(_loadingView.center.x, _loadingView.center.y+90.0);
        }
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
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
    
    [_activityIndicatorView startAnimating];
}

// 隐藏加载视图
- (void)hideLoadingView
{
    _loadingView.hidden = YES;
    [_activityIndicatorView stopAnimating];
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
