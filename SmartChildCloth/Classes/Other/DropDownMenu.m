//
//  DropDownMenu.m
//  ChildCloth
//
//  Created by Kitty on 16/7/14.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "DropDownMenu.h"

@interface DropDownMenu () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation DropDownMenu

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    DLog(@"dropDwonMenu%@",self.dataSource);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    
    return  self;
}

- (void)setup
{
    self.topView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:self.topView];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.topView.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.topView addSubview:self.tableView];
}

- (void)removeViewFromSuperView
{
    [self.topView removeFromSuperview];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.finishBlock(self.dataSource[indexPath.row]);
}

@end
