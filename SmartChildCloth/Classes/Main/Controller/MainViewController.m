//
//  MainViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "SocialViewController.h"
#import "BabyViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    HomeViewController *home = [[HomeViewController alloc]init];
    [self addChildViewController:home imageNamed:@"tabbar_home"];
    
    SocialViewController *social = [[SocialViewController alloc]init];
    [self addChildViewController:social imageNamed:@"tabbar_message_center"];
    
    BabyViewController *baby = [[BabyViewController alloc]init];
    [self addChildViewController:baby imageNamed:@"tabbar_profile"];
    
}

- (void)addChildViewController:(UIViewController *)childController imageNamed:(NSString *)imageName
{
    MainNavigationController *nav = [[MainNavigationController alloc] initWithRootViewController:childController];
    childController.tabBarItem.image = [[UIImage imageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", imageName]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置图片居中, 这儿需要注意top和bottom必须绝对值一样大
    childController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    // 设置导航栏为透明的
    //    if ([childController isKindOfClass:[ProfileController class]]) {
    //        [nav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //        nav.navigationBar.shadowImage = [[UIImage alloc] init];
    //        nav.navigationBar.translucent = YES;
    //    }
    [self addChildViewController:nav];
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
