//
//  ForgetPasswordViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "RootViewController.h"
#import "MainViewController.h"
#import "LeftMenuViewController.h"

@interface ForgetPasswordViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *phoneField;
@property (nonatomic,strong) UITextField *codeField;
@property (nonatomic,strong) UITextField *passwordField;
@property (nonatomic,strong) UIButton *sendCodeBtn;
@property (nonatomic,strong) UIButton *completeBtn;

@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NetWork *netWork;

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor= KblackgroundColor;
    self.title = @"忘记密码";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
    
    [self initView];
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
    self.phoneField.text = self.phone;
    
    // 验证码的边框
    UIButton *signBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn2.frame = CGRectMake(10, CGRectGetMaxY(self.phoneField.frame)+15, (SCREENWIDTH-30)*0.5, 50);
    signBtn2.backgroundColor = [UIColor whiteColor];
    [signBtn2.layer setMasksToBounds:YES];
    [signBtn2.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn2.layer setBorderWidth:1.0];   //边框宽度
    [signBtn2.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn2];
    
    self.codeField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.phoneField.frame)+15, (SCREENWIDTH-30)*0.5-10, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"请输入验证码";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        textField;
    });
    [self.view addSubview:self.codeField];

    self.sendCodeBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((SCREENWIDTH-30)*0.5+20, CGRectGetMaxY(self.phoneField.frame)+15, (SCREENWIDTH-30)*0.5, 50);
        button.backgroundColor = ButtonBgColor;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(getCodeClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.sendCodeBtn];
    
    // 密码的边框
    UIButton *signBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn3.frame = CGRectMake(10, CGRectGetMaxY(self.codeField.frame)+15, SCREENWIDTH-20, 50);
    signBtn3.backgroundColor = [UIColor whiteColor];
    [signBtn3.layer setMasksToBounds:YES];
    [signBtn3.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn3.layer setBorderWidth:1.0];   //边框宽度
    [signBtn3.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn3];
    
    self.passwordField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.codeField.frame)+15, SCREENWIDTH-30, 50)];
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
    
    
    self.completeBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, CGRectGetMaxY(self.passwordField.frame)+20, SCREENWIDTH-20, 50);
        button.backgroundColor = ButtonBgColor;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.completeBtn];

}

#pragma mark UITextFieldDelegate
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
- (void)getCodeClick:(UIButton *)sender
{
    NSString *url = @"parent/sendForgetCaptcha";
    if (!self.netWork) {
        self.netWork = [[NetWork alloc]init];
    }
    
    NSDictionary *parameter = @{@"phone":self.phoneField.text};
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                self.code = [NSString stringWithFormat:@"%@",[dict objectForKey:@"jsonResult"]];
                
                __block int timeout = 60; //倒计时时间
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
                dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
                dispatch_source_set_event_handler(_timer, ^{
                    if(timeout<=0){ //倒计时结束，关闭
                        dispatch_source_cancel(_timer);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //设置界面的按钮显示 根据自己需求设置
                            
                            [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                            [self.sendCodeBtn setAlpha:1];
                            self.sendCodeBtn.userInteractionEnabled = YES;
                            
                        });
                    }else{
                        int seconds = timeout % 60;
                        NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //设置界面的按钮显示 根据自己需求设置
                            DLog(@"____%@",strTime);
                            
                            [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%@s)",strTime] forState:UIControlStateNormal];
                            [self.sendCodeBtn setAlpha:0.8];
                            // but.backgroundColor = [UIColor grayColor];
                            self.sendCodeBtn.userInteractionEnabled = NO;
                            
                        });
                        timeout--;
                    }
                });
                dispatch_resume(_timer);
                
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

- (void)completeClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    NSString *url = @"parent/updatePassword";
    if (!self.netWork) {
        self.netWork = [[NetWork alloc]init];
    }
    NSDictionary *parameter = @{@"phone":self.phoneField.text, @"password":self.passwordField.text, @"captcha":self.codeField.text};
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
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
