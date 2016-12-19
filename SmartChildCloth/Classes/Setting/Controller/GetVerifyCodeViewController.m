//
//  GetVerifyCodeViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "GetVerifyCodeViewController.h"
#import "PasswordSettingViewController.h"

@interface GetVerifyCodeViewController ()

@property (nonatomic,strong) UILabel *phoneLabel;
@property (nonatomic,strong) UITextField *codeField;
@property (nonatomic,strong) UIButton *sendCodeBtn;
@property (nonatomic,strong) UIButton *nextBtn;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation GetVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"获取验证码";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
    
    [self initView];
}

- (void)initView
{
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 20)];
    label1.font = [UIFont systemFontOfSize:15];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"验证码已发送到手机号:";
    [self.view addSubview:label1];
    
    self.phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label1.frame), SCREENWIDTH, 20)];
    self.phoneLabel.font = [UIFont systemFontOfSize:15];
    self.phoneLabel.textAlignment = NSTextAlignmentCenter;
    self.phoneLabel.text = self.phone;
    [self.view addSubview:self.phoneLabel];
    
    // 验证码的边框
    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(10, CGRectGetMaxY(self.phoneLabel.frame)+30, (SCREENWIDTH-30)*0.5, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setMasksToBounds:YES];
    [signBtn1.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];
    
    self.codeField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.phoneLabel.frame)+30, (SCREENWIDTH-30)*0.5-10, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"请输入验证码";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField;
    });
    [self.view addSubview:self.codeField];
    
    self.sendCodeBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((SCREENWIDTH-30)*0.5+20, CGRectGetMaxY(self.phoneLabel.frame)+30, (SCREENWIDTH-30)*0.5, 50);
        button.backgroundColor = ButtonBgColor;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"获取验证码(60s)" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(getCodeClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button.userInteractionEnabled = NO;
        button.alpha = 0.8;
        button;
    });
    [self.view addSubview:self.sendCodeBtn];
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, CGRectGetMaxY(self.codeField.frame)+30, SCREENWIDTH-20, 50);
        button.backgroundColor = ButtonBgColor;
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.nextBtn];
    
    
    [self getCodeClick:self.sendCodeBtn];
}

#pragma mark - hide
- (void)keyboardHide:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark -
- (void)getCodeClick:(UIButton *)sender
{
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
    
    if ([self.sendCodeBtn.titleLabel.text isEqualToString:@"获取验证码"]) {
        self.netWork = [[NetWork alloc]init];
        NSDictionary *dict = @{@"phone":self.phone};
        NSString *url = @"parent/getCaptcha";
        [self.netWork httpNetWorkWithUrl:url WithBlock:dict block:^(NSData *data, NSError *error) {
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dic objectForKey:@"code"] intValue] == 0) {
                    
                    self.code = [NSString stringWithFormat:@"%@",[dic objectForKey:@"jsonResult"]];
                }
                else if ([[dic objectForKey:@"code"] intValue] == 10001) {
                    
                    // 如果已注册，弹出aleretView 登录
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您的手机号码已在平台注册，是否现在登录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alertView show];
                    
                }else{
                    [[UIApplication sharedApplication].keyWindow makeToast:[dic objectForKey:@"msg"]];
                }
                
            }else{
                
            }
        }];
    }
    
}

- (void)nextClick:(UIButton *)sender
{
    [self.view endEditing:YES];
#if 1
    if ([self.code isEqualToString:self.codeField.text]) {
        PasswordSettingViewController *vc = [[PasswordSettingViewController alloc]init];
        vc.phone = self.phone;
        vc.code = self.codeField.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        [[UIApplication sharedApplication].keyWindow makeToast:@"验证码不正确"];
    }
#endif
    
#if 0
    PasswordSettingViewController *vc = [[PasswordSettingViewController alloc]init];
    vc.phone = self.phone;
    vc.code = self.codeField.text;
    [self.navigationController pushViewController:vc animated:YES];
#endif
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
