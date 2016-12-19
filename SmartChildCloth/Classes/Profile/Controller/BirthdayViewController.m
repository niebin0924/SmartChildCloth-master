//
//  BirthdayViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "BirthdayViewController.h"
#import "HeightViewController.h"
#import "HMDatePickView.h"

@interface BirthdayViewController ()

@property (nonatomic,strong) UIImageView *genderImageView;
@property (nonatomic,strong) UILabel *birthdayLabel;
@property (nonatomic,strong) UIButton *nextBtn;

@end

@implementation BirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"生日";
    
    [self initView];
}

- (void)initView
{
    self.genderImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 60, 60)];
        imageView.center = CGPointMake(self.view.centerX, imageView.centerY);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (self.gender == 0) {
            // 男
            imageView.image = [UIImage imageNamed:@"boy"];
        }else {
            // 女
            imageView.image = [UIImage imageNamed:@"gril"];
        }
//        UIImage *image = [UIImage imageNamed:@"cont_ic_baby"];
//        imageView.image = [UIImage circleImage:image borderColor:[UIColor clearColor] borderWidth:0.f];
        imageView;
    });
    [self.view addSubview:self.genderImageView];
    
    self.birthdayLabel = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.genderImageView.frame)+10, SCREENWIDTH, 40)];
        label.center = CGPointMake(self.view.centerX, label.centerY);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:25];
        if (![self.birthday isEqualToString:@""] && self.birthday) {
            label.text = self.birthday;
        }else {
            label.text = @"选择生日";
        }
        label;
    });
    [self.view addSubview:self.birthdayLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    self.birthdayLabel.userInteractionEnabled = YES;
    [self.birthdayLabel addGestureRecognizer:tap];
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, SCREENHEIGHT-10-45-64, SCREENWIDTH-40, 45);
        button.backgroundColor = ButtonBgColor;
        if ([self.type isEqualToString:@"update"]) {
            [button setTitle:@"完成" forState:UIControlStateNormal];
        }else{
            [button setTitle:@"下一步" forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.nextBtn];
}

#pragma mark - 
- (void)tapAction
{
    HMDatePickView *datePickVC = [[HMDatePickView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //距离当前日期的年份差（设置最大可选日期）
    datePickVC.maxYear = -1;
    //设置最小可选日期(年分差)
    //    _datePickVC.minYear = 10;
    
    if ([self.birthday isEqualToString:@""]) {
       datePickVC.date = [NSDate date];
    }else{
       NSDate *date = [GLDateUtils dateForDescription:self.birthday];
        datePickVC.date = date;
    }
    //设置字体颜色
//    datePickVC.fontColor = [UIColor lightGrayColor];
    //日期回调
    datePickVC.completeBlock = ^(NSString *selectDate) {

        self.birthdayLabel.text = selectDate;
    };
    //配置属性
    [datePickVC configurationIsHasNavbar:YES];
    
    [self.view addSubview:datePickVC];
}

- (void)nextClick:(UIButton *)sender
{
    if ([self.birthdayLabel.text isEqualToString:@"选择生日"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请选择生日" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    
    if ([self.type isEqualToString:@"update"]) {
        
        NSString *url = @"child/updateChildInformation";
        NSString *token = [[AppDefaultUtil sharedInstance]getToken];
        JKEncrypt *encrypt = [[JKEncrypt alloc]init];
        token = [encrypt doDecEncryptStr:token];
        NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
        NSDictionary *parameters = @{@"token":token, @"childId":childId, @"birthday":self.birthdayLabel.text};
        
        NetWork *netWork = [[NetWork alloc]init];
        [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dict objectForKey:@"code"]integerValue] == 0) {
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:@"refresh_update"];
                    [defaults synchronize];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                }
                
            }else{
                if (error) {
                    
                }
            }
        }];
        
    }else{
        HeightViewController *vc = [[HeightViewController alloc]init];
        vc.nickName = self.nickName;
        vc.gender = self.gender;
        vc.birthday = self.birthdayLabel.text;
        vc.height = @"120"; // 初始值120
        vc.picImage = self.picImage;
        vc.type = @"add";
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
