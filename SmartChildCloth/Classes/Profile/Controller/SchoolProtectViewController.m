//
//  SchoolProtectViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "SchoolProtectViewController.h"
#import "AreaAddressViewController.h"
#import "AddNewAreaViewController.h"
#import "DeviceInfoViewController.h"
#import "DetailTextCell.h"
#import "SwitchCell.h"

@interface SchoolProtectViewController () <UITableViewDataSource,UITableViewDelegate,SafeAddressDelegate>
{
    NSInteger status;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *areaString;
@property (nonatomic,strong) NSString *homeAddress;
@property (nonatomic,strong) NSString *schoolAddress;

@end

static NSString *identifier1 = @"SwitchCell";
static NSString *identifier2 = @"DetailTextCell";
static NSString *identifier3 = @"Cell";

@implementation SchoolProtectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"上学守护";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick)];
    
    [self initData];
    
    [self initTable];
    
    [self request];
}

- (void)initData
{
    status = 0;
    self.dataArray = [NSMutableArray array];
    NSArray *oneArray = @[@"上学守护",@"铃声"];
    [self.dataArray addObject:oneArray];
    
    NSArray *twoArray = @[@{@"pic":@"ic_home1",@"title":@"家/小区",@"content":@"请设置安全地址"},@{@"pic":@"cont_ic_school1",@"title":@"学校",@"content":@"请设置安全地址"}];
    [self.dataArray addObject:twoArray];
}

- (void)initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:identifier1];
    [_tableView registerNib:[UINib nibWithNibName:@"DetailTextCell" bundle:nil] forCellReuseIdentifier:identifier2];
    [self.view addSubview:_tableView];
}

- (void)request
{
    NSString *url = @"guardian/getguardian";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    
    NSDictionary *parameter = @{@"token":token, @"eqId":eqId};
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                status = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]] integerValue];
                NSString *home_longitude = [NSString stringWithFormat:@"%@",[dict objectForKey:@"home_longitude"]];
                NSString *home_latitude = [NSString stringWithFormat:@"%@",[dict objectForKey:@"home_latitude"]];
                NSString *home_radius = [NSString stringWithFormat:@"%@",[dict objectForKey:@"home_radius"]];
                NSString *school_longitud = [NSString stringWithFormat:@"%@",[dict objectForKey:@"school_longitud"]];
                NSString *school_latitude = [NSString stringWithFormat:@"%@",[dict objectForKey:@"school_latitude"]];
                NSString *school_radius = [NSString stringWithFormat:@"%@",[dict objectForKey:@"school_radius"]];
                self.homeAddress = [self reverseGeocodeLongtitude:home_longitude WithLatitude:home_latitude];
                self.schoolAddress = [self reverseGeocodeLongtitude:school_longitud WithLatitude:school_latitude];
                
                [self.tableView reloadData];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
        
    }];
}

#pragma mark - Other
- (NSString *)reverseGeocodeLongtitude:(NSString *)longitude WithLatitude:(NSString *)latitude
{
    __block NSString *address;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             address = placemark.name;
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             DLog(@"city = %@", city);
            
             
         }
         else if (error == nil && [array count] == 0)
         {
             DLog(@"No results were returned.");
             address = @"";
         }
         else if (error != nil)
         {
             DLog(@"An error occurred = %@", error);
             address = @"";
         }
     }];
    
    return address;
}

#pragma mark - SafeAddressDelegate
- (void)updateAddress:(NSString *)addresss
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"refresh_update"]) {
        NSArray *twoArr = self.dataArray[1];
        NSMutableArray *tmpArr = [twoArr mutableCopy];
        if ([self.areaString isEqualToString:@"home"]) {
            
            NSDictionary *dic = tmpArr[0];
            
            
        }else{
            
        }
    }
    [defaults setBool:NO forKey:@"refresh_update"];
    [defaults synchronize];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            SwitchCell *cell = (SwitchCell *)[tableView dequeueReusableCellWithIdentifier:identifier1];
            
            NSArray *arr = self.dataArray[indexPath.section];
            cell.titleLabel.text = arr[indexPath.row];
            cell.openSwitch.on = status;
            [cell.openSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            
            return cell;
        }else{
            
            DetailTextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2 forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSArray *arr = self.dataArray[indexPath.section];
            cell.titleLabel.text = arr[indexPath.row];
            cell.detailLabel.text = @"默认";
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier3];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    NSArray *arr = self.dataArray[indexPath.section];
    NSDictionary *dict = arr[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[dict objectForKey:@"pic"]];
    cell.textLabel.text = [dict objectForKey:@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.text = [dict objectForKey:@"content"];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 55;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1) {
        AreaAddressViewController *vc = [[AreaAddressViewController alloc]init];
        vc.delegate = self;
        vc.titleString = cell.textLabel.text;
        NSInteger type = indexPath.row;
        if (type == 0) {
            type = 2;
            self.areaString = @"home";
        }else{
            self.areaString = @"school";
        }
        vc.type = [NSString stringWithFormat:@"%zd",type];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - 
- (void)switchChange:(UISwitch *)swi
{
    if ([[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@"<null>"] || [[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@""]) {
        
        [[UIApplication sharedApplication].keyWindow makeToast:@"请先绑定设备"];
        
        DeviceInfoViewController *vc = [[DeviceInfoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    // status:0关1开
    NSString *url = @"guardian/setswitch";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    NSDictionary *parameters = @{@"token":token, @"eqId":eqId, @"status":[NSString stringWithFormat:@"%d",swi.on]};
    
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"设置成功"];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                swi.on = !swi.on;
            }
            
        }else
        {
            if (error) {
                
            }
        }
    }];
}

- (void)addClick
{
    AddNewAreaViewController *vc = [[AddNewAreaViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
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
