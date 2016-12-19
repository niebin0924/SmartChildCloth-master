//
//  PasswordSettingViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "PasswordSettingViewController.h"
#import "RegistSucceedViewController.h"
#import "LoginViewController.h"

@interface PasswordSettingViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *passwordField;
@property (nonatomic,strong) UIButton *nextBtn;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation PasswordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"密码设置";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
    
    [self initView];
}

- (void)initView
{
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 20)];
    label1.font = [UIFont systemFontOfSize:15];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"请先输入您的密码";
    [self.view addSubview:label1];

    
    // 密码的边框
    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(10, CGRectGetMaxY(label1.frame)+20, SCREENWIDTH-20, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setMasksToBounds:YES];
    [signBtn1.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];
    
    self.passwordField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(label1.frame)+20, SCREENWIDTH-30, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"请设置密码";
        textField.font = [UIFont systemFontOfSize:14];
        textField.secureTextEntry = YES;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField;
    });
    [self.view addSubview:self.passwordField];
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, CGRectGetMaxY(self.passwordField.frame)+30, SCREENWIDTH-20, 50);
        button.backgroundColor = ButtonBgColor;
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.nextBtn];
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
- (void)nextClick:(UIButton *)sender
{
    [self.view endEditing:YES];
#if 1
    self.netWork = [[NetWork alloc]init];
    NSString *url = @"parent/register";
    NSDictionary *parameter =@{@"phone":self.phone, @"password":self.passwordField.text, @"captcha":self.code, @"phoneType":@"IOS"};
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dic objectForKey:@"code"] integerValue] == 0) {
                
                NSDictionary *acc = [dic objectForKey:@"jsonResult"];
                [self saveAccount:acc];
                
                LoginViewController *vc = [[LoginViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dic objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
#endif
    
#if 0
    LoginViewController *vc = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
#endif
}

- (void)saveAccount:(NSDictionary *)account
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    NSString *password = [encrypt doEncryptStr:self.passwordField.text];
    BOOL isSave = [SSKeychain setPassword:password forService:identifier account:self.phone];
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
    
    [[AppDefaultUtil sharedInstance] setAccount:self.phone];
    
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
