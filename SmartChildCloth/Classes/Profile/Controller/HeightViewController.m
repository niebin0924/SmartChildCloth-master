//
//  HeightViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "HeightViewController.h"
#import "WeightViewController.h"
#import "DLFRulerView.h"

/** rulerMultiple参数为控制缩放比 */
static CGFloat const rulerMultiple = 10;

/** 最大刻度值 */
static CGFloat const maxValue = 200;

/** 最小刻度值 */
static CGFloat const minValue = 10;

///** 默认刻度值 */
//static CGFloat const defatuleValue = 120;

@interface HeightViewController () <DLFRulerViewDelegate>

@property (nonatomic,strong) UIImageView *genderImageView;
@property (nonatomic,strong) UILabel *heightLabel;
@property (nonatomic,strong) UIButton *nextBtn;

@property (nonatomic,strong) DLFRulerView *ruleView;

@end

@implementation HeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KblackgroundColor;
    self.title = @"身高";
//    self.height = [NSString stringWithFormat:@"%.f",defatuleValue];
    [self initView];
}

- (void)initView
{
    self.genderImageView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 60, 60)];
        imageView.center = CGPointMake(self.view.centerX-60, self.view.centerY-120);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (self.gender == 0) {
            imageView.image = [UIImage imageNamed:@"boy"];
        }else{
            imageView.image = [UIImage imageNamed:@"gril"];
        }
        imageView;
    });
    [self.view addSubview:self.genderImageView];
    
    self.heightLabel = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.genderImageView.frame)+10, 120, 40)];
        label.center = CGPointMake(self.genderImageView.centerX, label.centerY);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:25];
        label.text = [NSString stringWithFormat:@"%@cm",self.height];
        label;
    });
    [self.view addSubview:self.heightLabel];
    
    self.nextBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, SCREENHEIGHT-10-45-64, SCREENWIDTH-40, 45);
        button.backgroundColor = ButtonBgColor;
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 2.f;
        button.layer.masksToBounds = YES;
        button;
    });
    [self.view addSubview:self.nextBtn];
    
    self.ruleView = ({
        DLFRulerView *rulerView = [[DLFRulerView alloc]initWithmaxValue:maxValue minValue:minValue rulerViewShowType:rulerViewshowVerticalType andRulerMultiple:rulerMultiple];
        rulerView.frame = CGRectMake(SCREENWIDTH-120, 0, 100, 300);
        rulerView.center = CGPointMake(rulerView.centerX, self.genderImageView.centerY);
        rulerView.defaultValue = [self.height floatValue];
        rulerView.clipsToBounds = YES;
        rulerView.layer.masksToBounds = YES;
        rulerView.layer.cornerRadius = 2.f;
        rulerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        rulerView.layer.borderWidth = 1.f;
        rulerView.delegate = self;
        rulerView.backgroundColor = [UIColor whiteColor];
        rulerView;
    });
    [self.view addSubview:self.ruleView];
    
    
}

#pragma mark - DLFRulerViewDelegate
- (void)getRulerValue:(CGFloat)rulerValue
{
    self.heightLabel.text = [NSString stringWithFormat:@"%.fcm",rulerValue];
    self.height = [NSString stringWithFormat:@"%.f",rulerValue];
}

#pragma mark -
- (void)nextClick:(UIButton *)sender
{
    if ([self.type isEqualToString:@"update"]) {
        
        NSString *url = @"child/updateChildInformation";
        NSString *token = [[AppDefaultUtil sharedInstance]getToken];
        JKEncrypt *encrypt = [[JKEncrypt alloc]init];
        token = [encrypt doDecEncryptStr:token];
        NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
        NSDictionary *parameters = @{@"token":token, @"childId":childId, @"high":self.height};
        
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
        WeightViewController *vc = [[WeightViewController alloc]init];
        vc.nickName = self.nickName;
        vc.gender = self.gender;
        vc.birthday = self.birthday;
        vc.height = self.height;
        vc.weight = @"30"; // 初始值30
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
