//
//  RootViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/12.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "RootViewController.h"
#import "LeftMenuViewController.h"
#import "MainViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableRESideMenu) name:@"disableRESideMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableRESideMenu) name:@"enableRESideMenu" object:nil];
    
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.8;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = NO;
    
    self.delegate = self;
}

- (void)enableRESideMenu {
    self.panGestureEnabled = YES;
}

- (void)disableRESideMenu {
    self.panGestureEnabled = NO;
}

#pragma mark - RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
