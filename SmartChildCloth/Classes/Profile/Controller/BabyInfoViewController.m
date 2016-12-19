//
//  BabyInfoViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "BabyInfoViewController.h"
#import "ImproveNicknameViewController.h"
#import "GenderViewController.h"
#import "BirthdayViewController.h"
#import "HeightViewController.h"
#import "WeightViewController.h"
#import "DetailTextCell.h"
#import "BaseModal.h"

@interface BabyInfoViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSInteger sex; // 0男1女
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIImageView *picImageView;

@property (nonatomic,strong) NetWork *netWork;

@end

static NSString *identifier = @"DetailTextCell";

@implementation BabyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"宝贝信息";
    
    [self initTable];
    
    [self request];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"refresh_update"]) {
        [self request];
    }
    [defaults setBool:NO forKey:@"refresh_update"];
    [defaults synchronize];
}

- (void)setDataWithName:(NSString *)nickname Sex:(NSString *)gender Birth:(NSString *)birthday High:(NSString *)height Weight:(NSString *)weight
{
    
    NSArray *names = @[@"昵称",@"性别",@"生日",@"身高",@"体重"];
    NSArray *contents = @[nickname,gender,birthday,[NSString stringWithFormat:@"%@cm",height],[NSString stringWithFormat:@"%@KG",weight]];
    self.dataArray = [NSMutableArray array];
    for (NSInteger i=0; i<names.count; i++) {
        BaseModal *modal = [[BaseModal alloc]init];
        modal.name = names[i];
        modal.content = contents[i];
        [self.dataArray addObject:modal];
    }
}

- (void)request
{
    self.netWork = [[NetWork alloc]init];
    NSString *url = @"child/getChildInformation";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
    NSDictionary *parameters = @{@"token":token, @"childId":childId};
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                NSDictionary *result = [dict objectForKey:@"jsonResult"];
                NSString *nickname = [NSString stringWithFormat:@"%@",[result objectForKey:@"name"]];
                sex = [[NSString stringWithFormat:@"%@",[result objectForKey:@"sex"]] integerValue];
                NSString *birthday = [NSString stringWithFormat:@"%@",[result objectForKey:@"birthday"]];
                NSString *height = [NSString stringWithFormat:@"%@",[result objectForKey:@"high"]];
                NSString *weight = [NSString stringWithFormat:@"%@",[result objectForKey:@"km"]];
                NSString *picUrl = [NSString stringWithFormat:@"%@",[result objectForKey:@"headUrl"]];
                NSString *gender;
                if (sex == 0) {
                    gender = @"男";
                }else{
                    gender = @"女";
                }
                
                [self setDataWithName:nickname Sex:gender Birth:birthday High:height Weight:weight];
                [[AppDefaultUtil sharedInstance] setHeadImageUrl:picUrl];
                [[AppDefaultUtil sharedInstance] setGender:sex];
                
                [self.tableView reloadData];
                
                [self.picImageView sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
        }else{
            if (error) {
                
            }
        }
    }];
}

- (void)initTable
{
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStyleGrouped];
        tableView.backgroundColor = KblackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerNib:[UINib nibWithNibName:@"DetailTextCell" bundle:nil] forCellReuseIdentifier:identifier];
        tableView;
    });
    [self.view addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 150)];
    headerView.backgroundColor = KblackgroundColor;
    
    self.picImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.picImageView.center = CGPointMake(headerView.centerX, headerView.centerY);
//    self.picImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.picImageView.layer.masksToBounds = YES;
    self.picImageView.layer.cornerRadius = 40.f;
//    NSInteger gender = [[AppDefaultUtil sharedInstance] getGender];
//    if (gender == 0) {
//        self.picImageView.image = [UIImage imageNamed:@"boy"];
//    }else{
//        self.picImageView.image = [UIImage imageNamed:@"gril"];
//    }

    [headerView addSubview:self.picImageView];
    
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 150)];
    footerView.backgroundColor = KblackgroundColor;
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteBtn.frame = CGRectMake(20, 40, SCREENWIDTH-40, 45);
    self.deleteBtn.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.8];
    [self.deleteBtn setTitle:@"删除宝贝" forState:UIControlStateNormal];
    self.deleteBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = 2.f;
    [self.deleteBtn addTarget:self action:@selector(deleteBabyClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.deleteBtn];
    
    self.tableView.tableFooterView = footerView;
}

- (void)deleteBabyClick:(UIButton *)sender
{
    if (![[[AppDefaultUtil sharedInstance] getEqId] isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请先解绑设备" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    
    NSString *url = @"child/deleteChildInformation";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    NSString *childId = [[AppDefaultUtil sharedInstance] getChildId];
    NSDictionary *parameters = @{@"token":token, @"childId":childId};
    
    [self.netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"]integerValue] == 0) {
                
                [[UIApplication sharedApplication].keyWindow makeToast:@"删除宝贝成功"];
                [[AppDefaultUtil sharedInstance] setChildId:@""];
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
            }
            
        }else{
            if (error) {
                
            }
        }
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    BaseModal *modal = self.dataArray[indexPath.row];
    cell.titleLabel.text = modal.name;
    cell.detailLabel.text = modal.content;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseModal *modal = self.dataArray[indexPath.row];
    
#if 1
    switch (indexPath.row) {
        case 0:
        {
            ImproveNicknameViewController *vc = [[ImproveNicknameViewController alloc]init];
            vc.type = @"update";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            GenderViewController *vc = [[GenderViewController alloc]init];
            vc.type = @"update";
            vc.gender = sex;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            BirthdayViewController *vc = [[BirthdayViewController alloc]init];
            vc.type = @"update";
            vc.gender = sex;
            vc.birthday = modal.content;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            HeightViewController *vc = [[HeightViewController alloc]init];
            vc.type = @"update";
            vc.height = [modal.content stringByReplacingOccurrencesOfString:@"cm" withString:@""];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            WeightViewController *vc = [[WeightViewController alloc]init];
            vc.type = @"update";
            vc.weight = [modal.content stringByReplacingOccurrencesOfString:@"KG" withString:@""];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
#endif
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
