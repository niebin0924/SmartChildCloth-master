//
//  JiBuViewController.m
//  ChildCloth
//
//  Created by dongshilin on 16/7/18.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "JiBuViewController.h"
#import "TextImageButton.h"

@interface JiBuViewController ()

@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) TextImageButton *homeBtn;
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIView *darkView;

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeTimeLabel;

@property (nonatomic,strong) NetWork *netWork;

@end

@implementation JiBuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initNavigationBar];
    [self initDatePicker];
    [self request];
}

- (void)initNavigationBar
{
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home_nav_ic-trajectory"] style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    //    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.titleView = ({
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        view;
    });
    
    self.homeBtn = [[TextImageButton alloc]init];
    [self.homeBtn setTitle:[self getTimeString:[NSDate date]] forState:UIControlStateNormal];
    [self.homeBtn setImage:[UIImage imageNamed:@"home_nav-ic_down"] forState:UIControlStateNormal];
    [self.homeBtn setImage:[UIImage imageNamed:@"home_nav-ic_down"] forState:UIControlStateHighlighted];
    [self.homeBtn addTarget:self action:@selector(dropDownMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.homeBtn];
    
    CGSize size = [[[AppDefaultUtil sharedInstance] getNickName] boundingRectWithSize:CGSizeMake(200, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]} context:nil].size;
    
    [self.homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(size.width+10, 44));
        make.centerX.mas_equalTo(@0);
        make.centerY.mas_equalTo(@0);
    }];
    
    
    self.navigationItem.titleView = self.titleView;
}

- (NSString *)getTimeString:(NSDate *)date
{
    NSString *weekday = [GLDateUtils weekdayStringFormDate:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM-dd";
    NSString *time = [formatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@ %@",weekday, time];
}

#pragma mark - UI
- (void)initDatePicker
{
    if (!_darkView) {
        _darkView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _darkView.backgroundColor = [UIColor colorWithWhite:.7 alpha:.3];
        _darkView.userInteractionEnabled = YES;
        [self.view addSubview:_darkView];
    }
    self.darkView.hidden = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture)];
    singleTap.numberOfTapsRequired = 1;
    [self.darkView addGestureRecognizer:singleTap];
    
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 5, 300, 80)];
    self.datePicker.centerX = self.darkView.centerX;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    NSDate *minDate = [GLDateUtils dateForYear:2016 Month:1 Day:1];
    NSDate *maxDate = [GLDateUtils dateForYear:2016 Month:12 Day:31];
    self.datePicker.minimumDate = minDate;
    self.datePicker.maximumDate = maxDate;
    [self.darkView addSubview:self.datePicker];
    self.datePicker.hidden = YES;
}

- (void)handleSingleTapGesture{
    self.darkView.hidden = YES;
    self.datePicker.hidden = YES;
}

#pragma mark -  request
- (void)request
{
    NSString *url = @"sport_info/details";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *eqId = [[AppDefaultUtil sharedInstance] getEqId];
    NSString *startTime = [GLDateUtils descriptionForDate:[NSDate date]];
    
    NSDictionary *parameter = @{@"token":token, @"eqId":eqId, @"startTime":startTime};
    self.netWork = [[NetWork alloc]init];
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                NSDictionary *result = [dict objectForKey:@"jsonResult"];
                self.stepLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"step"]];
                self.mileLabel.text = [NSString stringWithFormat:@"%@公里",[result objectForKey:@"mileage"]];
                self.calorieLabel.text = [NSString stringWithFormat:@"%@卡",[result objectForKey:@"calorie"]];
                self.activeTimeLabel.text = [NSString stringWithFormat:@"%@分钟",[result objectForKey:@"activeTime"]];
            }
            
        }else{
            if (error) {
                
            }
        }
        
    }];
}

#pragma mark - rightClick
- (void)rightClick
{
    
}

- (void)dropDownMenu:(UIButton *)sender
{
    self.darkView.hidden = NO;
    self.datePicker.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
