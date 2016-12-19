//
//  SettingViewController.m
//  ChildCloth
//
//  Created by cmfchina on 16/7/20.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "SettingViewController.h"
#import "ChangemimaVC.h"
#import "AboutAPPVC.h"
#import "WenTiViewController.h"
#import "GuideViewController.h"
#import "FileCacheHelper.h"
#import "DetailTextCell.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titleArr;
    NSArray *iamgeArr;
}

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"设置";
    
    titleArr = @[@"修改密码",@"清除缓存",@"关于APP",@"常见问题",@"推荐朋友",@"立即购买"];
    
    [self initTable];
}

- (void)initTable
{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailTextCell" bundle:nil] forCellReuseIdentifier:@"DetailTextCell"];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    footView.backgroundColor = [ColorTools colorWithHexString:@"#f0f0f0"];
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.frame = CGRectMake(10, 30, self.view.frame.size.width-20, 50);
    [but setBackgroundImage:[UIImage imageNamed:@"bt-exit_bg"] forState:UIControlStateNormal];
    [but setTitle:@"退出登录" forState:UIControlStateNormal];
    [footView addSubview:but];
    [but addTarget:self action:@selector(clickBut) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = footView;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 4;
    }else
    {
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 1){
        DetailTextCell *detailCell = [tableView dequeueReusableCellWithIdentifier:@"DetailTextCell" forIndexPath:indexPath];
        detailCell.titleLabel.text = [titleArr objectAtIndex:indexPath.row];
        
        float folderSize = [FileCacheHelper folderSizeAtPath:@""];
        detailCell.detailLabel.text = [NSString stringWithFormat:@"%.1fM",folderSize];
        
        return detailCell;
        
    }
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    if(indexPath.section == 0 && indexPath.row != 1)
    {
        cell.textLabel.text = [titleArr objectAtIndex:indexPath.row];
        
    }else
    {
        cell.textLabel.text = [titleArr objectAtIndex:indexPath.row+4];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//cell的右边有一个小箭头，距离右边有十几像素；
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            ChangemimaVC *mima = [[ChangemimaVC alloc]init];
            [self.navigationController pushViewController:mima animated:YES];
        }else if (indexPath.row == 1) {
            // 清除缓存
//            NSString *path = [[NSBundle mainBundle] bundleIdentifier];
            [FileCacheHelper clearCache:@""];
            
            [SVProgressHUD showSuccessWithStatus:@"清除缓存成功"];
            
            [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationFade];
        
        }
        else if(indexPath.row == 2)
        {
            AboutAPPVC *about = [[AboutAPPVC alloc]init];
            [self.navigationController pushViewController:about animated:YES];

        }else if(indexPath.row == 3)
        {
            WenTiViewController *wenti = [[WenTiViewController alloc]init];
            [self.navigationController pushViewController:wenti animated:YES];
        }
    }else
    {
        
    }
}

#pragma mark - Action
-(void)clickBut
{
    NSString *url = @"parent/logout";

    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSDictionary *parameters = @{@"token":token};
    NetWork * netWoking = [[NetWork alloc]init];
    [netWoking httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
        if(data)
        {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if([[dic objectForKey:@"code"] intValue] == 0)
            {
                [[UIApplication sharedApplication].keyWindow makeToast:@"退出登录成功"];
                
                
                dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(timer, dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                    [UIApplication sharedApplication].keyWindow.rootViewController = [[GuideViewController alloc]init];
                    LoginViewController *login = [[LoginViewController alloc]init];
                    MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:login];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
                });
                
                
                
                
            }else
            {
                [[UIApplication sharedApplication].keyWindow makeToast:[dic objectForKey:@"msg"]];
            }
        }else
        {
            if(error)
            {
                
            }
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
