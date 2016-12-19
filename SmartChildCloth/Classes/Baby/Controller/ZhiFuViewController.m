//
//  ZhiFuViewController.m
//  ChildCloth
//
//  Created by cmfchina on 16/7/19.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "ZhiFuViewController.h"

@interface ZhiFuViewController ()
{
    NSInteger payMode;
}

@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *package1;
@property (weak, nonatomic) IBOutlet UIButton *package2;
@property (weak, nonatomic) IBOutlet UIButton *package3;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@end

@implementation ZhiFuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"支付服务费";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.nameLabel.text = [[AppDefaultUtil sharedInstance] getNickName];
    
    [self request];
}

- (void)request
{
    NSString *url = @"order/getmenu";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameters = @{@"token":token, @"eqId":eqId};
    [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                NSArray *result = [dict objectForKey:@"jsonResult"];
                if (result && result.count > 0) {
                    
                    for (NSInteger i=0; i<result.count; i++) {
                        NSDictionary *d = [result objectAtIndex:i];
                        NSString *total = [NSString stringWithFormat:@"%@",[d objectForKey:@"total"]];
                        NSString *amount = [NSString stringWithFormat:@"%@",[d objectForKey:@"amount"]];
                        NSString *discount = [NSString stringWithFormat:@"%@",[d objectForKey:@"discount"]];
                        NSString *payable = [NSString stringWithFormat:@"%@",[d objectForKey:@"payable"]];
                        
                        NSInteger day = [total integerValue]/30;
                        
                        if (i==0) {
                            if (day == 1) {
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/月",amount] forState:UIControlStateNormal];
                            }else if (day == 6) {
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/办年",amount] forState:UIControlStateNormal];
                            }else{
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/年",amount] forState:UIControlStateNormal];
                            }
                            
                        }else if (i==1) {
                            if (day == 1) {
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/月",amount] forState:UIControlStateNormal];
                            }else if (day == 6) {
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/办年",amount] forState:UIControlStateNormal];
                            }else{
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/年",amount] forState:UIControlStateNormal];
                            }
                        }else{
                            if (day == 1) {
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/月",amount] forState:UIControlStateNormal];
                            }else if (day == 6) {
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/办年",amount] forState:UIControlStateNormal];
                            }else{
                                [self.package1 setTitle:[NSString stringWithFormat:@"%@元/年",amount] forState:UIControlStateNormal];
                            }
                        }
                    }
                    
                }else{
                    
                }
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }

            
        }else{
            if (error) {
                
            }
        }
        
    }];
}

- (void)requestZhifuOrder
{
    NSString *url = @"order/list";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameters = @{@"token":token};
    [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                NSArray *result = [dict objectForKey:@"jsonResult"];
                if (result && result.count > 0) {
                    
                    
                    
                    
                }else{
                    
                }
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
            
        }else{
            if (error) {
                
            }
        }
        
    }];
}

#pragma mark - button click
- (IBAction)priceone:(id)sender {
    UIButton *but1 = (UIButton *)[self.view viewWithTag:200];
    UIButton *but2 = (UIButton *)[self.view viewWithTag:210];
    UIButton *but3 = (UIButton *)[self.view viewWithTag:220];
    but1.layer.borderWidth = 1;
    but1.layer.borderColor = [[UIColor redColor]CGColor];
    but2.layer.borderWidth = 0;
    but3.layer.borderWidth = 0;
}

- (IBAction)pricetwo:(id)sender {
    UIButton *but1 = (UIButton *)[self.view viewWithTag:200];
    UIButton *but2 = (UIButton *)[self.view viewWithTag:210];
    UIButton *but3 = (UIButton *)[self.view viewWithTag:220];
    but2.layer.borderWidth = 1;
    but2.layer.borderColor = [[UIColor redColor]CGColor];
    but1.layer.borderWidth = 0;
    but3.layer.borderWidth = 0;
}

- (IBAction)pricethree:(id)sender {
    UIButton *but1 = (UIButton *)[self.view viewWithTag:200];
    UIButton *but2 = (UIButton *)[self.view viewWithTag:210];
    UIButton *but3 = (UIButton *)[self.view viewWithTag:220];
    but3.layer.borderWidth = 1;
    but3.layer.borderColor = [[UIColor redColor]CGColor];
    but1.layer.borderWidth = 0;
    but2.layer.borderWidth = 0;
}

- (IBAction)zhifubao:(id)sender {
    UIButton *but1 = (UIButton *)[self.view viewWithTag:100];
    UIButton *but2 = (UIButton *)[self.view viewWithTag:110];
    UIButton *but3 = (UIButton *)[self.view viewWithTag:120];
    [but1 setBackgroundImage:[UIImage imageNamed:@"circle_dot"] forState:UIControlStateNormal];
    [but2 setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [but3 setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    payMode = 1;
}

- (IBAction)weixin:(id)sender {
    UIButton *but1 = (UIButton *)[self.view viewWithTag:100];
    UIButton *but2 = (UIButton *)[self.view viewWithTag:110];
    UIButton *but3 = (UIButton *)[self.view viewWithTag:120];
    [but1 setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [but2 setBackgroundImage:[UIImage imageNamed:@"circle_dot"] forState:UIControlStateNormal];
    [but3 setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    payMode = 2;
}

- (IBAction)yinhangka:(id)sender {
    UIButton *but1 = (UIButton *)[self.view viewWithTag:100];
    UIButton *but2 = (UIButton *)[self.view viewWithTag:110];
    UIButton *but3 = (UIButton *)[self.view viewWithTag:120];
    [but1 setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [but2 setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [but3 setBackgroundImage:[UIImage imageNamed:@"circle_dot"] forState:UIControlStateNormal];
}

#pragma mark - 付款
- (IBAction)fukuan:(id)sender {
    
    NSString *url = @"order/pay";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameters = @{@"token":token, @"eqId":eqId, @"menuid":@"", @"total":@"", @"amount":@"", @"discount":@"", @"payable":@"", @"mode_payment":[NSString stringWithFormat:@"%zd",payMode]};
    [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                
                
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
        
    }];
}
@end
