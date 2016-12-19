//
//  ChangemimaVC.m
//  ChildCloth
//
//  Created by cmfchina on 16/7/20.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "ChangemimaVC.h"
#import "ColorTools.h"

@interface ChangemimaVC () <UITextFieldDelegate>

@end

@implementation ChangemimaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"修改密码";
    self.view.backgroundColor = [ColorTools colorWithHexString:@"#f0f0f0"];

    self.jiumima.delegate = self;
    self.xinmima.delegate = self;
    self.querenmima.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tap];
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

- (IBAction)queding:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([self.jiumima.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入旧密码"];
        return;
    }
    if ([self.xinmima.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入新密码"];
        return;
    }
    
    if (![self.xinmima.text isEqualToString:self.querenmima.text]) {
        
        [SVProgressHUD showInfoWithStatus:@"两次输入不一致"];
        return;
    }
    
    NSString *url = @"parent/resetPassword";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSDictionary *parameter = @{@"token":token, @"oldPsw":self.jiumima.text, @"newPsw1":self.xinmima.text, @"newPsw2":self.querenmima.text};
    NetWork *netWork = [[NetWork alloc]init];
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"修改密码成功"];
                
            }else {
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}
@end
