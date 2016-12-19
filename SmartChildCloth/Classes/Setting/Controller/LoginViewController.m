//
//  LoginViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "LeftMenuViewController.h"
#import "RootViewController.h"
#import "RegistSucceedViewController.h"
#import "ScanBindDeviceViewController.h"
#import "ImproveNicknameViewController.h"
#import "RegistViewController.h"
#import "ForgetPasswordViewController.h"
#import "Baby.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *phoneField;
@property (nonatomic,strong) UITextField *passwordField;
@property (nonatomic,strong) UIButton *forgetButton;
@property (nonatomic,strong) UIButton *loginBtn;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"登录";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(regist)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
    
    
    [self initView];
    
    if (![self.phoneField.text isEqualToString:@""] && ![self.passwordField.text isEqualToString:@""]) {
        [self loginClick:nil];
    }
}

- (void)initView
{
    // 手机的边框
    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(10, 10, SCREENWIDTH-20, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setMasksToBounds:YES];
    [signBtn1.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];

    self.phoneField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 10, SCREENWIDTH-30, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"手机";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField;
    });
    [self.view addSubview:self.phoneField];
    
    NSString *account = [[AppDefaultUtil sharedInstance] getAccount];
    if (![account isEqualToString:@""] && account) {
        self.phoneField.text = account;
    }
    
    // 密码的边框
    UIButton *signBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn2.frame = CGRectMake(10, CGRectGetMaxY(self.phoneField.frame)+15, SCREENWIDTH-20, 50);
    signBtn2.backgroundColor = [UIColor whiteColor];
    [signBtn2.layer setMasksToBounds:YES];
    [signBtn2.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn2.layer setBorderWidth:1.0];   //边框宽度
    [signBtn2.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn2];
    
    self.passwordField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.phoneField.frame)+15, SCREENWIDTH-30, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"密码";
        textField.font = [UIFont systemFontOfSize:14];
        textField.secureTextEntry = YES;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField;
    });
    [self.view addSubview:self.passwordField];
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *str = [SSKeychain passwordForService:identifier account:self.phoneField.text];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    NSString *pwd = [encrypt doDecEncryptStr:str];
    if (pwd) {
        self.passwordField.text = pwd;
    }
    
    self.forgetButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(SCREENWIDTH-110, CGRectGetMaxY(self.passwordField.frame)+5, 100, 20);
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [button setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(forgetPassswordClick:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:self.forgetButton];
    
    self.loginBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, CGRectGetMaxY(self.passwordField.frame)+40, SCREENWIDTH-20, 50);
        button.backgroundColor = ButtonBgColor;
        [button setTitle:@"登录" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.loginBtn];
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
- (void)loginClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    [SVProgressHUD show];
    
    self.netWork = [[NetWork alloc]init];
    NSString *url = @"parent/login";
    NSDictionary *parameter;
    if ([[AppDefaultUtil sharedInstance] getClientId] == nil) {
        parameter = @{@"account":self.phoneField.text, @"password":self.passwordField.text};
    }else{
        parameter = @{@"account":self.phoneField.text, @"password":self.passwordField.text, @"clientid":[[AppDefaultUtil sharedInstance] getClientId]};
    }
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dic objectForKey:@"code"] integerValue] == 0) {
                
                NSDictionary *acc = [dic objectForKey:@"jsonResult"];
                [self saveAccount:acc];
                

                NSArray *childs = [acc objectForKey:@"childs"];
                if (childs.count > 0 && childs) {
                    if ([[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@"<null>"]) {
                        
                        // 绑定设备
                        ScanBindDeviceViewController *vc = [[ScanBindDeviceViewController alloc]init];
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    }
                    else if ([[[AppDefaultUtil sharedInstance] getChildId] isEqualToString:@"<null>"]) {
                        
                        ImproveNicknameViewController *vc = [[ImproveNicknameViewController alloc]init];
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    }
                    else{
                        RootViewController *vc = [[RootViewController alloc]initWithContentViewController:[[MainViewController alloc]init] leftMenuViewController:[[LeftMenuViewController alloc]init] rightMenuViewController:nil];
                        [self presentViewController:vc animated:YES completion:^{}];
                    }
                    
                }
                else{
                    // 登录->没有宝贝->添加宝贝绑定设备
                    RegistSucceedViewController *vc = [[RegistSucceedViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dic objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
    
    
}

- (void)saveAccount:(NSDictionary *)account
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    NSString *password = [encrypt doEncryptStr:self.passwordField.text];
    BOOL isSave = [SSKeychain setPassword:password forService:identifier account:self.phoneField.text];
    if (isSave) {
        DLog(@"保存用户密码成功");
    }
    
    NSString *value = [SSKeychain passwordForService:identifier account:@"isFirstInstall"];
    if (![value isEqualToString:@"1"]) {
        
        BOOL isSave = [SSKeychain setPassword:@"1" forService:identifier account:@"isFirstInstall"];
        if (isSave) {
            DLog(@"保存keychain成功");
        }
    }
    
    NSString *token = [NSString stringWithFormat:@"%@",[account objectForKey:@"token"]];
    // 设备是否过期，0：正常，1：过期
    BOOL isExpired = [[NSString stringWithFormat:@"%@",[account objectForKey:@"isExpired"]] boolValue];
    if (isExpired) {
        // 充值
    }
//    NSString *name = [NSString stringWithFormat:@"%@",[account objectForKey:@"uName"]];
//    NSString *headUrl = [NSString stringWithFormat:@"%@",[account objectForKey:@"uheadUrl"]];
    [[AppDefaultUtil sharedInstance] setAccount:self.phoneField.text];
    [[AppDefaultUtil sharedInstance] setToken:[encrypt doEncryptStr:token]];
    
    NSArray *childs = [account objectForKey:@"childs"];
    NSMutableArray *dataArray = [NSMutableArray array];
    if (childs && childs.count > 0) {
        for (NSDictionary *child in childs) {
            
            Baby *baby = [[Baby alloc]init];
            baby.name = [NSString stringWithFormat:@"%@",[child objectForKey:@"name"]];
            baby.childId = [NSString stringWithFormat:@"%@",[child objectForKey:@"childId"]];
            baby.eqId = [NSString stringWithFormat:@"%@",[child objectForKey:@"eqId"]];
            baby.headUrl = [NSString stringWithFormat:@"%@",[child objectForKey:@"headUrl"]];
            
            // 将baby类型变为NSData类型
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:baby];
            // 存储
            [dataArray addObject:data];
            
            if ([childs indexOfObject:child] == 0) {
                [[AppDefaultUtil sharedInstance] setNickName:baby.name];
                [[AppDefaultUtil sharedInstance] setHeadImageUrl:baby.headUrl];
                [[AppDefaultUtil sharedInstance] setEqId:baby.eqId];
                [[AppDefaultUtil sharedInstance] setChildId:baby.childId];
            }
        }
        
        // NSUserDefaults 存储的对象全是不可变的
        NSArray *array = [NSArray arrayWithArray:dataArray];
        [[AppDefaultUtil sharedInstance] setChilds:array];
    }
    
    /*
    // 取出
    NSArray *babys = [[AppDefaultUtil sharedInstance] getChilds];
    for (NSData *data in babys) {
        Baby *b = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        DLog(@"baby:eqId=%@ name=%@ headUrl=%@ childId=%@",b.eqId,b.name,b.headUrl,b.childId);
    }
     */
}

- (void)forgetPassswordClick:(UIButton *)sender
{
    ForgetPasswordViewController *vc = [[ForgetPasswordViewController alloc]init];
    vc.phone = self.phoneField.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)regist
{
    RegistViewController *vc = [[RegistViewController alloc]init];
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
