//
//  LeftMenuViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "MessageCenterViewController.h"
#import "SchoolProtectViewController.h"
#import "DeviceInfoViewController.h"
#import "BabyInfoViewController.h"
#import "SmartSavePowerViewController.h"
#import "DeviceListViewController.h"

@interface LeftMenuViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) NSArray *imageArray;

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UIImageView *headImageView;

@end

static NSString *reuseIdentifier = @"Cell";

@implementation LeftMenuViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[AppDefaultUtil sharedInstance] getChildId] isEqualToString:@""] || [[[AppDefaultUtil sharedInstance] getChildId] isEqualToString:@"<null>"]) {
        
        self.nameLabel.text = @"";
        self.headImageView.image = [UIImage imageNamed:@"default_headpic"];
        
    }else{
        self.nameLabel.text = [[AppDefaultUtil sharedInstance] getNickName];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KColor;
    
    self.dataArray = @[@"消息记录",@"上学守护",@"设备信息",@"宝贝信息",@"智能节电",@"设备列表"];
    self.imageArray = @[@"social_ic_comm",@"social_ic_comm",@"social_ic_comm",@"social_ic_comm",@"social_ic_comm",@"social_ic_comm"];
    
    
    
    [self initView];
}

- (void)initView
{
    
    [self initTable];
    
    UIButton *bluetoothBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-60, 120, 120)];
    bluetoothBtn.centerX = self.headImageView.centerX;
    bluetoothBtn.backgroundColor = ButtonBgColor;
    [bluetoothBtn setTitle:@"蓝牙随行" forState:UIControlStateNormal];
    [bluetoothBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bluetoothBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    bluetoothBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    bluetoothBtn.titleEdgeInsets = UIEdgeInsetsMake(15, 0, 0, 0);
    bluetoothBtn.layer.masksToBounds = YES;
    bluetoothBtn.layer.cornerRadius = bluetoothBtn.width * 0.5;
    [bluetoothBtn addTarget:self action:@selector(bluetoothClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bluetoothBtn];
}

- (void)initTable
{
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width*0.75, 45*self.dataArray.count+120) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = KColor;
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        tableView.rowHeight = 45.f;
        tableView;
    });
    
    self.tableView.tableHeaderView = [self headerView];
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self.view addSubview:self.tableView];
}

- (UIView *)headerView
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, 120)];
    
    self.nameLabel = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, headView.width, 30)];
        label.centerX = headView.centerX;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
        label;
    });
    [headView addSubview:self.nameLabel];
    
    self.headImageView = ({
       UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        imageView.centerX = headView.centerX;
        imageView.y = self.nameLabel.y+self.nameLabel.height+10;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 30.f;
        imageView;
    });
    
    [headView addSubview:self.headImageView];
    
    self.nameLabel.text = [[AppDefaultUtil sharedInstance] getNickName];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    
    return headView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    
    UIView *selView =  [[UIView alloc]init];
    selView.backgroundColor = KColor;
    cell.selectedBackgroundView = selView;
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = KColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            MessageCenterViewController *vc = [[MessageCenterViewController alloc]init];
            MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 1:
        {
            SchoolProtectViewController *vc = [[SchoolProtectViewController alloc]init];
            MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 2:
        {
            DeviceInfoViewController *vc = [[DeviceInfoViewController alloc]init];
            MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 3:
        {
            BabyInfoViewController *vc = [[BabyInfoViewController alloc]init];
            MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 4:
        {
            SmartSavePowerViewController *vc = [[SmartSavePowerViewController alloc]init];
            MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 5:
        {
            DeviceListViewController *vc = [[DeviceListViewController alloc]init];
            MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController.sideMenuViewController hideMenuViewController];
}

- (void)bluetoothClick
{
    // 当未连接的时候，点击按钮就继续连接
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
