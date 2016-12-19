//
//  AddNewAreaViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "AddNewAreaViewController.h"

@interface AddNewAreaViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *nameField;

@end

@implementation AddNewAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置新区域名称";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextClick)];

    UIButton *signBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    signBtn1.frame = CGRectMake(0, 40, SCREENWIDTH, 50);
    signBtn1.backgroundColor = [UIColor whiteColor];
    [signBtn1.layer setBorderWidth:1.0];   //边框宽度
    [signBtn1.layer setBorderColor:KlayerBorder.CGColor];//边框颜色
    [self.view addSubview:signBtn1];
    
    self.nameField = ({
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 40, SCREENWIDTH-10, 50)];
        textField.font = [UIFont systemFontOfSize:16];
        textField.borderStyle = UITextBorderStyleNone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.placeholder = @"请输入新区域名称";
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField;
    });
    [self.view addSubview:self.nameField];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 
- (void)nextClick
{
    [self.nameField resignFirstResponder];
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
