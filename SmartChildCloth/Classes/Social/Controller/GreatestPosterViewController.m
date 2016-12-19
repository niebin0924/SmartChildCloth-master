//
//  GreatestPosterViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/10/24.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "GreatestPosterViewController.h"
#import "QuanZiTableViewCell.h"
#import "Poster.h"
#import "HJCActionSheet.h"

@interface GreatestPosterViewController () <UITableViewDelegate,UITableViewDataSource,HJCActionSheetDelegate,popSheetDelegate>
{
    NSInteger currPage;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) QuanZiTableViewCell *selectCell;

@end

@implementation GreatestPosterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"精选";
    currPage = 1;
    self.dataArray = [NSMutableArray array];
    
    [self initTable];
    
}

- (void)initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-150-49-64-50) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"QuanZiTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [[UIView alloc]init];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(request)];
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self request];
    }];

    [_tableView.mj_header beginRefreshing];
}

- (void)request
{
    NSString *url = @"circle/findHandPickPost";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    if ([self.tableView.mj_header isRefreshing]) {
        currPage = 1;
        [self.dataArray removeAllObjects];
        
    }else if ([self.tableView.mj_footer isRefreshing]){
        currPage ++;
    }
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameter = @{@"token":token, @"pageSize":@"10", @"currentPage":[NSString stringWithFormat:@"%zd",currPage]};
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                
                NSArray *result = [dict objectForKey:@"jsonResult"];
                if (result && result.count > 0) {
                    
                    [self jsonData:result];
                    
                }else{
                    [SVProgressHUD showInfoWithStatus:@"无更多帖子"];
                    currPage = 1;
                }
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            }
            
        }else{
            if (error) {
                
            }
        }
    }];
}

- (void)collectPoster
{
    NSString *url = @"collect/collectPost";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
    NSString *collectTime = [NSString stringWithFormat:@"%ld-%02ld-%02ld-%02ld-%02ld-%02ld",components.year,components.month,components.day,components.hour,components.minute,components.second];
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameter = @{@"token":token, @"circleId":self.selectCell.circleId, @"collectTime":collectTime};
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {

                [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
                NSMutableArray *array = [self.dataArray mutableCopy];
                for (Poster *modal in array) {
                    if ([self.selectCell.circleId isEqualToString:modal.circleId]) {
                        modal.collected = YES;
                        [self.selectCell fillCellWithModal:modal];
                    }
                }
                self.dataArray = array;
                
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                
            }
            
        }else{
            if (error) {
                
            }
        }
        
    }];
}

- (void)uncollectPoster
{
    NSString *url = @"collect/uncollectpost";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameter = @{@"token":token, @"circleId":self.selectCell.circleId};
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [SVProgressHUD showSuccessWithStatus:@"取消收藏成功"];
                NSMutableArray *array = [self.dataArray mutableCopy];
                for (Poster *modal in array) {
                    if ([self.selectCell.circleId isEqualToString:modal.circleId]) {
                        modal.collected = NO;
                        [self.selectCell fillCellWithModal:modal];
                    }
                }
                
                
                self.dataArray = array;
                
                
            }else{
                [[UIApplication sharedApplication].keyWindow makeToast:[dict objectForKey:@"msg"]];
                
            }
            
        }else{
            if (error) {
                
            }
        }
        
    }];

}

- (void)jsonData:(NSArray *)result
{
    for (NSDictionary *dic in result) {
        
        Poster *modal = [[Poster alloc]init];
        modal.circleId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"circleId"]];
        modal.collected = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"collected"]] boolValue];
        modal.isHandpick = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"isHandpick"]] boolValue];
        modal.circlePicture = [NSString stringWithFormat:@"%@",[dic objectForKey:@"circlePicture"]];
        modal.title = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
        modal.content = [NSString stringWithFormat:@"%@",[dic objectForKey:@"content"]];
        NSString *dateTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"date"]];
        modal.dateTime = [dateTime substringWithRange:NSMakeRange(0, 19)];
        modal.headUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"headImg"]];
        modal.posterId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"posterId"]];
        modal.posterName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"poster"]];
        
        CGFloat titleHeight = [modal.title boundingRectWithSize:CGSizeMake(SCREENWIDTH-20, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f]} context:nil].size.height;
        
        CGFloat contentHeight = [modal.content boundingRectWithSize:CGSizeMake(SCREENWIDTH-20, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} context:nil].size.height;
        
        modal.height = 67 + titleHeight + contentHeight + 10 + 21 ;
        
        [self.dataArray addObject:modal];
        
    }
    
    [self.tableView reloadData];
}

#pragma mark--UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell1 = @"Cell";
    QuanZiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1 forIndexPath:indexPath];
    
    cell.delegate = self;
       
    Poster *modal = self.dataArray[indexPath.row];
    [cell fillCellWithModal:modal];
    
    return  cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Poster *modal = self.dataArray[indexPath.row];
    return modal.height;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - popSheetDelegate
- (void)popSheetDelegate:(QuanZiTableViewCell *)cell
{
    HJCActionSheet *sheet;
    self.selectCell = cell;
    
    if (self.selectCell.collected) {
        
         sheet = [[HJCActionSheet alloc]initWithDelegate:self CancelTitle:@"取消" OtherTitles:@"取消收藏", nil];
    }else{
         sheet = [[HJCActionSheet alloc]initWithDelegate:self CancelTitle:@"取消" OtherTitles:@"收藏", nil];
    }
    
   
    [sheet show];
    
    
}

#pragma mark HJCActionSheetDelegate
- (void)actionSheet:(HJCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        if (self.selectCell.collected) {
            [self uncollectPoster];
        }else{
        
            [self collectPoster];
        }
    }
}

@end
