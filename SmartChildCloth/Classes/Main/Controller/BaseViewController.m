//
//  BaseViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "BaseViewController.h"
#import "GuideViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"nav_ic_arrow_left"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}


- (void)back
{
    // 方法一:
//    if ([self.presentingViewController isKindOfClass:[GuideViewController class]] && self.navigationController.viewControllers.count < 2) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//
//    }else{
//        [self.navigationController popViewControllerAnimated:YES];
//    }

    // 方法二:
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1]==self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
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
