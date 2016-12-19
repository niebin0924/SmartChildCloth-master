//
//  RegistSucceedViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "RegistSucceedViewController.h"
#import "ImproveNicknameViewController.h"


@interface RegistSucceedViewController ()

@end

@implementation RegistSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"登录成功";
    
    [self initView];
}

- (void)initView
{
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 20)];
    label1.font = [UIFont systemFontOfSize:15];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"您已登录成功，请先完善宝贝信息";
    [self.view addSubview:label1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, CGRectGetMaxY(label1.frame)+40, 160, 50);
    button.center = CGPointMake(self.view.centerX, button.centerY);
    button.backgroundColor = ButtonBgColor;
    [button setTitle:@"完善宝贝信息" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bindClick:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 2.f;
    button.layer.masksToBounds = YES;
    [self.view addSubview:button];
}

#pragma mark - 

- (void)bindClick:(UIButton *)sender
{
    ImproveNicknameViewController *vc = [[ImproveNicknameViewController alloc]init];
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
