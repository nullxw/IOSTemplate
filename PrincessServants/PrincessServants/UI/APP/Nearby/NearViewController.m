//
//  NearViewController.m
//  PrincessServants
//
//  Created by tixa on 14-9-5.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import "NearViewController.h"
#import "PSPerson.h"

@interface NearViewController ()

@property (nonatomic, strong) UIView *topView;

@end

@implementation NearViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.showSearchBar =YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"附近";
    
    PSPerson *p1 = [[PSPerson alloc] init];
    p1.name = @"帅哥1";
    p1.age = @"23岁";
    p1.distance = @"距离1千米以内";
    p1.info = @"在这个看脸的时代，我已经不需要理由了。";
    
    PSPerson *p2 = [[PSPerson alloc] init];
    p2.name = @"帅哥2";
    p2.age = @"24岁";
    p2.distance = @"距离1千米以内";
    p2.info = @"做任务小能手，一切任您吩咐！";
    
    PSPerson *p3 = [[PSPerson alloc] init];
    p3.name = @"帅哥3";
    p3.age = @"22岁";
    p3.distance = @"距离1千米以内";
    p3.info = @"专业仆人二十年";
    
    PSPerson *p4 = [[PSPerson alloc] init];
    p4.name = @"帅哥4";
    p4.age = @"21岁";
    p4.distance = @"距离1千米以内";
    p4.info = @"只想做一个安静的美男子";
    
    PSPerson *p5 = [[PSPerson alloc] init];
    p5.name = @"帅哥5";
    p5.age = @"19岁";
    p5.distance = @"距离1千米以内";
    p5.info = @"大家都说好，用过才知道。";
    [self.dataArray addObjectsFromArray:@[p1, p2, p3, p4, p5]];
    [self reloadTable];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sf_navibar_back_white"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClicked:)];
    [self setLeftBarButtonItems:@[leftBarButtonItem]];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sf_navibar_back_white"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked:)];
    [self setRightBarButtonItems:@[rightBarButtonItem]];
    
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 24.0)];
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -20.0, 100.0, 44.0)];
    topLabel.font = [UIFont boldSystemFontOfSize:18.0];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = @"附近";
    [_topView addSubview:topLabel];
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 9.0, 100.0, 20.0)];
    bottomLabel.font = [UIFont systemFontOfSize:11.0];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = @"只看男仆";
    bottomLabel.tag = 888;
    [_topView addSubview:bottomLabel];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80.0, 9.0, 20.0, 20.0)];
    imageView.backgroundColor = [UIColor redColor];
    imageView.tag = 999;
    [_topView addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:_topView.bounds];
    [button addTarget:self action:@selector(dd:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:button];
    self.navigationItem.titleView = _topView;
    
}

- (void)dd:(UIButton *)button
{
    UILabel *bottomLabel = (UILabel *)[_topView viewWithTag:888];
    bottomLabel.text = @"只看女主";
    UIImageView *imageView = (UIImageView *)[_topView viewWithTag:999];
    imageView.backgroundColor = [UIColor greenColor];
}

- (void)leftBarButtonItemClicked:(id)sender
{
    NSLog(@"左侧按钮被点击了");
}


- (void)rightBarButtonItemClicked:(id)sender
{
    NSLog(@"右侧按钮被点击了");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (void)tableView:(UITableView *)tableView setupCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    PSPerson *person = [self.dataArray objectAtIndex:indexPath.row];
    // 头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 5.0, 50.0, 50.0)];
    imageView.backgroundColor = [UIColor greenColor];
    [cell.contentView addSubview:imageView];
    float x = imageView.frame.size.width+imageView.frame.origin.x+5.0;
    
    // 距离
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-160.0, 5.0, 150.0, 20.0)];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.font = [UIFont systemFontOfSize:14.0];
    distanceLabel.textAlignment = NSTextAlignmentRight;
    distanceLabel.text = person.distance;
    [cell.contentView addSubview:distanceLabel];
    
    // 姓名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 5.0, 150.0, 20.0)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16.0];
    nameLabel.text = person.name;
    [cell.contentView addSubview:nameLabel];
    // 年龄
    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 25.0, self.tableView.frame.size.width-x-10.0, 20.0)];
    ageLabel.backgroundColor = [UIColor clearColor];
    ageLabel.font = [UIFont systemFontOfSize:14.0];
    ageLabel.text = person.age;
    [cell.contentView addSubview:ageLabel];
    
    // 年龄
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 45.0, self.tableView.frame.size.width-x-10.0, 20.0)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont systemFontOfSize:14.0];
    infoLabel.text = person.info;
    [cell.contentView addSubview:infoLabel];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
