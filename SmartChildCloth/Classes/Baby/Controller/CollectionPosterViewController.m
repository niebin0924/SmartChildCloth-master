//
//  CollectionPosterViewController.m
//  SmartChildCloth
//
//  Created by Kitty on 16/12/5.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "CollectionPosterViewController.h"
#import "QuanZiTableViewCell.h"
#import "Poster.h"
#import "HJCActionSheet.h"

@interface CollectionPosterViewController () <UITableViewDelegate,UITableViewDataSource,popSheetDelegate,HJCActionSheetDelegate>
{
    NSInteger currPage;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) QuanZiTableViewCell *selectCell;

@end

@implementation CollectionPosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"收藏的帖子";
    self.view.backgroundColor = [UIColor whiteColor];
    currPage = 1;
    self.dataArray = [NSMutableArray array];
    
    [self initTable];
}

- (void)initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
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
    NSString *url = @"collect/collectPostList";
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

- (void)deletePoster
{
    NSString *url = @"circle/deleteMyPost";
    NSString *token = [[AppDefaultUtil sharedInstance]getToken];
    JKEncrypt *encrypt = [[JKEncrypt alloc]init];
    token = [encrypt doDecEncryptStr:token];
    
    NetWork *netWork = [[NetWork alloc]init];
    NSDictionary *parameter = @{@"token":token, @"circleId":self.selectCell.circleId};
    [netWork httpNetWorkWithUrl:url WithBlock:parameter block:^(NSData *data, NSError *error) {
        
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                
                NSMutableArray *array = [self.dataArray mutableCopy];
                for (Poster *modal in array) {
                    if ([self.selectCell.circleId isEqualToString:modal.circleId]) {
                        
                        NSInteger index = [array indexOfObject:modal];
                        [self.dataArray removeObject:modal];
                        [self.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
                
                
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
        
        modal.height = 67 + titleHeight + contentHeight + 10 + 21;
        
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
    self.selectCell = cell;
  
    HJCActionSheet *sheet = [[HJCActionSheet alloc]initWithDelegate:self CancelTitle:@"取消" OtherTitles:@"取消收藏",@"删除", nil];
   
    
    [sheet show];
}

#pragma mark HJCActionSheetDelegate
- (void)actionSheet:(HJCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
       
        [self uncollectPoster];
        
        
    }else if (buttonIndex == 2){
        
        [self deletePoster];
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
