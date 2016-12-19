//
//  RegistViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "RegistViewController.h"
#import "GetVerifyCodeViewController.h"
#import "LoginViewController.h"

@interface RegistViewController () <UIAlertViewDelegate>

@property (nonatomic,strong) UITextField *phoneField;
@property (nonatomic,strong) UIButton *nextBtn;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"手机号";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];

    
    [self initView];
}

- (void)initView
{
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 20)];
    label1.font = [UIFont systemFontOfSize:15];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"请先输入您的手机号码";
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label1.frame), SCREENWIDTH, 20)];
    label2.font = [UIFont systemFontOfSize:15];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"(注：请用家和手机号码注册账号)";
    [self.view addSubview:label2];
    
    // 手机的边框
    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(10, CGRectGetMaxY(label2.frame)+40, SCREENWIDTH-20, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setMasksToBounds:YES];
    [signBtn1.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];
    
    self.phoneField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(label2.frame)+40, SCREENWIDTH-30, 50)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholder = @"手机";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeyNext;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField;
    });
    [self.view addSubview:self.phoneField];
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, CGRectGetMaxY(self.phoneField.frame)+40, SCREENWIDTH-20, 50);
        button.backgroundColor = ButtonBgColor;
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.nextBtn];
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
    NSDictionary *dict = @{@"phone":self.phoneField.text};
    NSString *url = @"parent/getCaptcha";
    [self.netWork httpNetWorkWithUrl:url WithBlock:dict block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dic objectForKey:@"code"] intValue] == 0) {
                
                GetVerifyCodeViewController *vc = [[GetVerifyCodeViewController alloc]init];
                vc.phone = self.phoneField.text;
                vc.code = [NSString stringWithFormat:@"%@",[dic objectForKey:@"jsonResult"]];
                [self.navigationController pushViewController:vc animated:YES];
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
#endif
    
#if 0
    GetVerifyCodeViewController *vc = [[GetVerifyCodeViewController alloc]init];
    vc.phone = self.phoneField.text;
    [self.navigationController pushViewController:vc animated:YES];
#endif
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        LoginViewController *vc = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
