//
//  GuideViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#define BtnWidth (SCREENWIDTH-80)/2
#define BtnHeight 60

#import "GuideViewController.h"
#import "LeftMenuViewController.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "RegistViewController.h"

@interface GuideViewController ()

@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) UIButton *registBtn;

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.backImageView.image = [UIImage imageNamed:@"Stars"];
    [self.view addSubview:self.backImageView];
    
    self.loginBtn = ({
        UIButton *button = [[UIButton alloc]init];
        button.frame = CGRectMake(20, SCREENHEIGHT-20-BtnHeight, BtnWidth, BtnHeight);
        [button setTitle:@"登录" forState:UIControlStateNormal];
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        button.layer.borderWidth = 1.f;
        button;
    });
    [self.view addSubview:self.loginBtn];
    
    self.registBtn = ({
        UIButton *button = [[UIButton alloc]init];
        button.frame = CGRectMake(20+40+BtnWidth, SCREENHEIGHT-20-BtnHeight, BtnWidth, BtnHeight);
        [button setTitle:@"注册" forState:UIControlStateNormal];
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        button.layer.borderWidth = 1.f;
        button;
    });
    [self.view addSubview:self.registBtn];
    
    [self.loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.registBtn addTarget:self action:@selector(registBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loginBtnClick:(UIButton *)sender
{
    LoginViewController *vc = [[LoginViewController alloc]init];
    MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)registBtnClick:(UIButton *)sender
{
    RegistViewController *vc = [[RegistViewController alloc]init];
    MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)presentLogin
{
    LoginViewController *vc = [[LoginViewController alloc]init];
    MainNavigationController *nav = [[MainNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:NO completion:nil];
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
