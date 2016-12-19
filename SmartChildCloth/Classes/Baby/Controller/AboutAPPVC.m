//
//  AboutAPPVC.m
//  ChildCloth
//
//  Created by cmfchina on 16/7/20.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "AboutAPPVC.h"

@interface AboutAPPVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titleArr;
}

@end

@implementation AboutAPPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"关于APP";
    self.view.backgroundColor = [ColorTools colorWithHexString:@"#f0f0f0"];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    imageView.center = CGPointMake(self.view.centerX, 80);
    imageView.image = [UIImage imageNamed:@"app_icon"];
    [self.view addSubview:imageView];
    
    UITableView *myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 100) style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.scrollEnabled = NO;
    [self.view addSubview:myTableView];
    
    titleArr = @[@"检查更新",@"去评分"];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 260,  self.view.frame.size.width, 20)];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = @"当前版本是1.0";
    lable.textColor = [UIColor grayColor];
    [self.view addSubview:lable];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.text = [titleArr objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//cell的右边有一个小箭头，距离右边有十几像素；
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
