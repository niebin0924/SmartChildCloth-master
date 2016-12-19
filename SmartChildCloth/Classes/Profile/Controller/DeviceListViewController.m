//
//  DeviceListViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/10/18.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "DeviceListViewController.h"
#import "ImproveNicknameViewController.h"
#import "DeviceListCell.h"

@interface DeviceListViewController () <UITableViewDataSource,UITableViewDelegate,EditClickDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NetWork *netWork;
@property (nonatomic,strong) NSIndexPath *indexpath;

@end

@implementation DeviceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加宝贝" style:UIBarButtonItemStylePlain target:self action:@selector(addBaby)];
    
    NSArray *arr = @[@"大宝",@"二宝",@"小宝"];
    NSArray *arr2 = @[@"797757979898906",@"697757979898906",@"497757979898906"];
    self.dataArray = [NSMutableArray array];
    for (NSInteger i=0; i<3; i++) {
        DeviceList *modal = [[DeviceList alloc]init];
        modal.iconName = @"http://123.57.164.156:8080/smart_child_cloth/upload/BabyPictures/f70b6417a39341aca4e6e7b45ead84ac.jpg";
        modal.name = arr[i];
        modal.deviceNo = arr2[i];
        [self.dataArray addObject:modal];
    }
    
    [self initTable];
    
//    [self request];
}

- (void)initTable
{
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStyleGrouped];
        tableView.backgroundColor = KblackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[DeviceListCell class] forCellReuseIdentifier:@"deviceListCell"];
        tableView.rowHeight = 80.f;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

- (void)request
{
    NSString *url = @"";
    NSDictionary *paramters = @{};
    self.netWork = [[NetWork alloc]init];
    [self.netWork httpNetWorkWithUrl:url WithBlock:paramters block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
            }else {
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"deviceListCell";
    DeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    cell.indexpath = indexPath;
    
    DeviceList *modal = self.dataArray[indexPath.section];
    [cell fillCellWithObject:modal];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        [self.dataArray removeObjectAtIndex:indexPath.section];
//        [self.tableView deleteSection:indexPath.section withRowAnimation:UITableViewRowAnimationFade];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要解绑该设备吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        
        self.indexpath = indexPath;
    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EditClickDelegate
- (void)editClick:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要解绑该设备吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    
    self.indexpath = indexPath;
    
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self unBindDevice];
    }
}

#pragma mark - 解绑
- (void)unBindDevice
{
    DeviceList *modal = self.dataArray[self.indexpath.section];
    
    NSString *url = @"eq/removeEq";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSDictionary *parameter = @{@"token":token, @"model":modal.deviceNo};
    self.netWork = [[NetWork alloc]init];
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"解绑成功"];
                [self.dataArray removeObjectAtIndex:self.indexpath.section];
                [self.tableView deleteSection:self.indexpath.section withRowAnimation:UITableViewRowAnimationFade];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

#pragma mark - 添加宝贝
- (void)addBaby
{
    ImproveNicknameViewController *vc = [[ImproveNicknameViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
