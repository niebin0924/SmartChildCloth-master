//
//  BabyViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "BabyViewController.h"
#import "BadyTableViewCell.h"
#import "SetTableViewCell.h"
#import "JiBuViewController.h"
#import "ZhiFuViewController.h"
#import "SettingViewController.h"
#import "CollectionPosterViewController.h"

@interface BabyViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *myTableView;
    NSArray *titleArr;
    NSArray *imageArr;
    
    UIView *backView;
    UIWindow *keyWindow;
    UIButton *closeBut;
    UIButton *openBut;
    UIButton *chongqiBut;
}

@property (nonatomic,strong) BadyTableViewCell *headCell;

@end

@implementation BabyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"宝贝";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController)];
    
    titleArr = @[@"运动足迹",@"支付服务费",@"收藏夹",@"APP设置"];
    imageArr = @[@"baby_ic_foot",@"baby_ic_pay",@"baby_ic_keep",@"baby_ic_set"];

    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, ViewHeight)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
    UIView *view = [[UIView alloc]init];
    myTableView.tableFooterView = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.headCell != nil) {
    
        [self.headCell.photoImge sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_headpic"]];
        self.headCell.name.text = [[AppDefaultUtil sharedInstance] getNickName];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArr.count+1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        BadyTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"BadyTableViewCell" owner:nil options:nil] lastObject];
        self.headCell = cell;
        cell.photoImge.layer.masksToBounds = YES;
        cell.photoImge.layer.cornerRadius = 25.f;
        [cell.photoImge sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_headpic"]];
        cell.name.text = [[AppDefaultUtil sharedInstance] getNickName];
        return cell;
    }else
    {
        SetTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SetTableViewCell" owner:nil options:nil] lastObject];
        cell.cellImageView.image = [UIImage imageNamed:[imageArr objectAtIndex:indexPath.row-1]];
        cell.cellTitle.text = [titleArr objectAtIndex:indexPath.row-1];
        return cell;
    }
}

#pragma mark UITableViewDelegate
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 70;
    }else
    {
        return 50;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1)
    {
        JiBuViewController *jibu = [[JiBuViewController alloc]init];
        jibu.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:jibu animated:YES];
    }
    else if(indexPath.row == 2)
    {
        ZhiFuViewController *zhifu = [[ZhiFuViewController alloc]init];
        zhifu.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:zhifu animated:YES];
    }else if(indexPath.row == 3)
    {
        // 收藏夹
        CollectionPosterViewController *vc = [[CollectionPosterViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 4)
    {
        SettingViewController *setting = [[SettingViewController alloc]init];
        setting.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }
}

#pragma mark - touch
-(void)switchOnWindow
{
    keyWindow = [UIApplication sharedApplication].keyWindow;
    backView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    backView.alpha = 0.5;
    backView.backgroundColor = [UIColor blackColor];
    [keyWindow addSubview:backView];
    
    UIControl *control = [[UIControl alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [control addTarget:self action:@selector(dimissViewFromWindow) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:control];
    
    closeBut = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBut.frame = CGRectMake(0, 0, 70, 100);
    closeBut.center = keyWindow.center;
    [closeBut setBackgroundImage:[UIImage imageNamed:@"ic_off"] forState:UIControlStateNormal];
    [closeBut addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:closeBut];
    
    openBut = [UIButton buttonWithType:UIButtonTypeCustom];
    openBut.frame = CGRectMake(0, 0, 70, 100);
    openBut.center = CGPointMake(keyWindow.centerX, keyWindow.centerY-130);
    [openBut setBackgroundImage:[UIImage imageNamed:@"ic_on"] forState:UIControlStateNormal];
    [openBut addTarget:self action:@selector(openBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:openBut];
    
    chongqiBut = [UIButton buttonWithType:UIButtonTypeCustom];
    chongqiBut.frame = CGRectMake(0, 0, 70, 100);
    chongqiBut.center = CGPointMake(keyWindow.centerX, keyWindow.centerY+130);
    [chongqiBut setBackgroundImage:[UIImage imageNamed:@"ic_rest"] forState:UIControlStateNormal];
    [chongqiBut addTarget:self action:@selector(chongqiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:chongqiBut];
    

}

-(void)dimissViewFromWindow
{
    [closeBut removeFromSuperview];
    [openBut removeFromSuperview];
    [chongqiBut removeFromSuperview];
    [backView removeFromSuperview];
}

#pragma mark - Action Handle
- (void)presentLeftMenuViewController
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

// status:1
-(void)closeBtnClick:(UIButton *)but
{
    NSString *url = @"remote/setstatus";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    NSDictionary *parameter = @{@"token":token, @"eqId":eqId, @"status":@"1"};
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"设置成功"];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
        }else{
            if (error) {
                
            }
        }
    }];
}

// status:2 要求定位
-(void)openBtnClick:(UIButton *)but
{
    NSString *url = @"remote/setstatus";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    NSDictionary *parameter = @{@"token":token, @"eqId":eqId, @"status":@"2"};
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"设置成功"];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
        }else{
            if (error) {
                
            }
        }
    }];
}

// status:3 关闭定位
-(void)chongqiBtnClick:(UIButton *)but
{
    NSString *url = @"remote/setstatus";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    NSDictionary *parameter = @{@"token":token, @"eqId":eqId, @"status":@"3"};
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"设置成功"];
            }
            else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
        }else{
            if (error) {
                
            }
        }
    }];

}
@end
