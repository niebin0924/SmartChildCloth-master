//
//  HandBindDeviceViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "HandBindDeviceViewController.h"
#import "ScanBindDeviceViewController.h"
#import "RootViewController.h"
#import "MainViewController.h"
#import "LeftMenuViewController.h"

@interface HandBindDeviceViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *deviceField;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation HandBindDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"手动绑定设备";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"qr_scan_line@"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(scanBindDevice)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
    
    [self initView];
}

- (void)initView
{
    // 设备的边框
    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(10, 15, SCREENWIDTH-20, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setMasksToBounds:YES];
    [signBtn1.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];
    
    self.deviceField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 15, SCREENWIDTH-30, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"请输入需绑定的设备号";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField;
    });
    [self.view addSubview:self.deviceField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, CGRectGetMaxY(self.deviceField.frame)+30, SCREENWIDTH-20, 50);
    button.center = CGPointMake(self.view.centerX, button.centerY);
    button.backgroundColor = ButtonBgColor;
    [button setTitle:@"绑定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bindClick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 2.f;
    button.layer.masksToBounds = YES;
    [self.view addSubview:button];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - hide
- (void)keyboardHide:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark -
- (void)bindClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *account = [[AppDefaultUtil sharedInstance] getAccount];
//    NSArray *accounts = [SSKeychain accountsForService:identifier];
    
    NSString *password = [SSKeychain passwordForService:identifier account:account];
    DLog(@"pwd = %@",password);
#if 1
    NSString *url = @"eq/bingEq";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
//    self.deviceField.text = @"867567865767685";
    NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
    NSDictionary *parameter = @{@"token":token, @"model":self.deviceField.text, @"childId":childId};
    self.netWork = [[NetWork alloc]init];
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                NSDictionary *acc = [dict objectForKey:@"jsonResult"];
                [self saveAccount:acc];
                
                RootViewController *vc = [[RootViewController alloc]initWithContentViewController:[[MainViewController alloc]init] leftMenuViewController:[[LeftMenuViewController alloc]init] rightMenuViewController:nil];
                [self presentViewController:vc animated:YES completion:^{}];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
#endif
#if 0
    RootViewController *vc = [[RootViewController alloc]initWithContentViewController:[[MainViewController alloc]init] leftMenuViewController:[[LeftMenuViewController alloc]init] rightMenuViewController:nil];
    [self presentViewController:vc animated:YES completion:^{}];
#endif
}

- (void)saveAccount:(NSDictionary *)account
{
    NSString *eqId = [NSString stringWithFormat:@"%@",[account objectForKey:@"eqId"]];
    [[AppDefaultUtil sharedInstance] setEqId:eqId];
}

- (void)scanBindDevice
{
    ScanBindDeviceViewController *vc = [[ScanBindDeviceViewController alloc]init];
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
