//
//  DeviceInfoViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "DeviceInfoViewController.h"
#import "ScanBindDeviceViewController.h"
#import "DeviceHeaderView.h"
#import "DetailTextCell.h"
#import "DeviceInfo.h"

@interface DeviceInfoViewController () <UITableViewDataSource,UITableViewDelegate,QRCodeScannerViewControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *unBindBtn;
@property (nonatomic,strong) UIButton *bindBtn;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) NetWork *netWork;

@end

static NSString *identifier = @"DetailTextCell";

@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备信息";
    
    [self initData];
    
    [self initView];
    
    [self request];
}

- (void)initData
{
    self.dataArray = [NSMutableArray array];
    
    // 0section
    NSMutableArray *arr = [NSMutableArray array];
    DeviceInfo *modal = [[DeviceInfo alloc]init];
    modal.name = @"设备型号";
    modal.content = @"";
    [arr addObject:modal];
    [self.dataArray addObject:arr];
    
    // 1section
    NSArray *names = @[@"GPS",@"WIFI",@"陀螺仪",@"体温传感器"];
    NSArray *contens = @[@"主要用于室外定位",@"主要用于室内定位",@"主要用于运动计步",@"主要用于体温检测"];
    NSMutableArray *arr2 = [NSMutableArray array];
    for (NSInteger i=0; i<4; i++) {
        
        DeviceInfo *modal = [[DeviceInfo alloc]init];
        modal.name = names[i];
        modal.content = contens[i];
        [arr2 addObject:modal];
        
    }
    [self.dataArray addObject:arr2];
}

- (void)initView
{
    [self initTable];
    
    self.unBindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.unBindBtn.frame = CGRectMake(20, self.view.height-5-45-64, SCREENWIDTH-40, 45);
    self.unBindBtn.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.8];
    [self.unBindBtn setTitle:@"解除绑定" forState:UIControlStateNormal];
    self.unBindBtn.layer.masksToBounds = YES;
    self.unBindBtn.layer.cornerRadius = 2.f;
    [self.unBindBtn addTarget:self action:@selector(unBindClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.unBindBtn];
    
    self.tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, SCREENWIDTH, 40)];
    self.tipLabel.font = [UIFont systemFontOfSize:15.f];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.text = @"您未绑定设备,请先绑定设备";
    self.tipLabel.hidden = YES;
    [self.view addSubview:self.tipLabel];
    
    self.bindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bindBtn.frame = CGRectMake(20, 150, SCREENWIDTH-40, 45);
    self.bindBtn.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.8];
    [self.bindBtn setTitle:@"绑定设备" forState:UIControlStateNormal];
    self.bindBtn.layer.masksToBounds = YES;
    self.bindBtn.layer.cornerRadius = 2.f;
    [self.bindBtn addTarget:self action:@selector(bindDevice) forControlEvents:UIControlEventTouchUpInside];
    self.bindBtn.hidden = YES;
    [self.view addSubview:self.bindBtn];
    
    if ([[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@""] || [[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@"<null>"]) {
        
        self.tableView.hidden = YES;
        self.unBindBtn.hidden = YES;
        self.bindBtn.hidden = NO;
        self.tipLabel.hidden = NO;
        
    }
}

- (void)request
{
    if ([[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@""] || [[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@"<null>"]) {
        return;
    }
    
    NSString *url = @"equipment/details";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSDictionary *parameter = @{@"token":token, @"eqId":[[AppDefaultUtil sharedInstance]getEqId]};
    self.netWork = [[NetWork alloc]init];
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                NSArray *result = [[dict objectForKey:@"jsonResult"] objectForKey:@"details"];
                if (result && result.count > 0) {
                    
                    NSDictionary *dic = result[0];
                    
                    NSMutableArray *arr0 = self.dataArray[0];
                    NSMutableArray *arr = [arr0 mutableCopy];
                    DeviceInfo *modal = arr[0];
                    modal.content = [NSString stringWithFormat:@"%@",[dic objectForKey:@"modelNumber"]];
                    arr0 = arr;
                }
                
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

- (void)initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64-60) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"DetailTextCell" bundle:nil] forCellReuseIdentifier:identifier];
    [self.view addSubview:_tableView];
    
    DeviceHeaderView *headerView = [[NSBundle mainBundle]loadNibNamed:@"DeviceHeaderView" owner:self options:nil][0];
//    UIImageView *subImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [subImageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    
    UIImage *subImage;
    if ([[AppDefaultUtil sharedInstance] getGender] == 0) {
        // 男
        subImage = [UIImage imageNamed:@"boy"];
    }else{
        subImage = [UIImage imageNamed:@"gril"];
    }
    
    headerView.codeImageView.image = [QRCScanner scQRCodeForString:[[AppDefaultUtil sharedInstance]getEqId] size:headerView.codeImageView.bounds.size.width fillColor:[UIColor blackColor] subImage:[UIImage imageNamed:@"default_headpic"]];
    
    headerView.nameLabel.text = [NSString stringWithFormat:@"%@的二维码",[[AppDefaultUtil sharedInstance] getNickName]];
    headerView.deviceNumberLabel.text = [[AppDefaultUtil sharedInstance] getEqId];
    self.tableView.tableHeaderView = headerView;
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
    DetailTextCell *cell = (DetailTextCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    DeviceInfo *modal = self.dataArray[indexPath.section][indexPath.row];
    cell.titleLabel.text = modal.name;
    cell.detailLabel.text = modal.content;
    
    return cell;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return @"";
//    }
//    
//    return @"配置";
//}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return nil;
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    sectionView.backgroundColor = KblackgroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 40, 20)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor lightGrayColor];
    label.text = @"配置";
    [sectionView addSubview:label];
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - QRCodeScannerViewControllerDelegate
- (void)didFinshedScanning:(NSString *)result{
    DLog(@"扫描到的结果=%@",result);
}

#pragma mark - 解除绑定
- (void)unBindClick:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否要解除绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self unBindDevice];
    }
}


#pragma mark - 解除绑定
- (void)unBindDevice
{
    // 当前如果仅绑定了此设备，如果解除绑定后将返回到绑定设备界面。2、当前账号绑定了多个设备，如果解除当前设备绑定状态后，将返回主页
    
    NSString *url = @"eq/removeEq";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSDictionary *parameter = @{@"token":token, @"model":[[AppDefaultUtil sharedInstance]getEqId]};
    //    self.netWork = [[NetWork alloc]init];
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"解绑成功"];
                [[AppDefaultUtil sharedInstance] setEqId:@""];
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

#pragma mark - 绑定
- (void)bindDevice
{
    ScanBindDeviceViewController *vc = [[ScanBindDeviceViewController alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
- (void)bindClick:(UIButton *)sender
{
    ScanBindDeviceViewController *vc = [[ScanBindDeviceViewController alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
*/
 
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
