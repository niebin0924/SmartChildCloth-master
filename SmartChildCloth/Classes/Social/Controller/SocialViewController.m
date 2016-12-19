//
//  SocialViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "SocialViewController.h"
#import "GreatestPosterViewController.h"
#import "CirclePosterViewController.h"
#import "MyPosterViewController.h"
#import "TieZiViewController.h"
#import "HYPageView.h"


@interface SocialViewController ()



@property (nonatomic,strong) UIImageView *headImageView;



@end

@implementation SocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"社交";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavigationBar];
    
    [self configUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[AppDefaultUtil sharedInstance] getChildId] isEqualToString:@""] || [[[AppDefaultUtil sharedInstance] getChildId] isEqualToString:@"<null>"]) {
        
        self.headImageView.image = [UIImage imageNamed:@"default_headpic"];
        
    }else{

        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[[AppDefaultUtil sharedInstance] getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    }
}

- (void)initNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"set_ic_write"] style:UIBarButtonItemStylePlain target:self action:@selector(faTieZi)];
}

- (void)configUI
{
    // social_top_bg
    UIImageView *headView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 150)];
    headView.image = [UIImage imageNamed:@"social_top_bg"];
    [self.view addSubview:headView];
    
    self.headImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        imageView.center = CGPointMake(headView.centerX, headView.centerY);
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 40.f;
        imageView;
    });
    [headView addSubview:self.headImageView];
    
    
    HYPageView *pageView = [[HYPageView alloc] initWithFrame:CGRectMake(0, 150, SCREENWIDTH, SCREENHEIGHT-150-49) withTitles:@[@"精选",@"圈子",@"我的"] withViewControllers:@[@"GreatestPosterViewController",@"CirclePosterViewController",@"MyPosterViewController"] withParameters:nil];
//    pageView.isTranslucent = NO;
    pageView.isAnimated = YES;
    pageView.selectedColor = KColor;
    pageView.unselectedColor = [UIColor blackColor];
    [self.view addSubview:pageView];
}



#pragma mark - Action
- (void)presentLeftMenuViewController
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)faTieZi
{
    TieZiViewController *tieZi = [[TieZiViewController alloc]init];
    tieZi.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tieZi animated:YES];
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
