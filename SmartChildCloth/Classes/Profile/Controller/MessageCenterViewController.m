//
//  MessageCenterViewController.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "MessageCenterViewController.h"
#import "MessageCenterCell.h"
#import "MessageCenter.h"

@interface MessageCenterViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    BOOL isDelete; // 是否为删除状态
    NSInteger currPage;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation MessageCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"消息中心";
    isDelete = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editClick)];
    
    [self initData];
    
    [self initTable];
}

- (void)initData
{
    self.dataArray = [NSMutableArray array];
    currPage = 1;
}

- (void)initTable
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self request];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self request];
    }];
    [_tableView.mj_header beginRefreshing];
}

- (void)request
{
    NSString *url = @"message/details";
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
    NSDictionary *parameters = @{@"token":token, @"currentPage":[NSString stringWithFormat:@"%zd",currPage], @"pagSize":@"10"};
    [netWork httpNetWorkWithUrl:url WithBlock:parameters block:^(NSData *data, NSError *error) {
       
        if (data) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"code"] integerValue] == 0) {
                
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                
                NSArray *result = [dict objectForKey:@"jsonResult"];
                if (result && result.count > 0) {
                    
                    [self jsonData:result];
                    
                }else{
                    [SVProgressHUD showInfoWithStatus:@"无消息"];
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

- (void)jsonData:(NSArray *)result
{
    for (NSDictionary *dict in result) {
        MessageCenter *modal = [[MessageCenter alloc]init];
        modal.messageId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
        modal.isRead = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]] boolValue];
        modal.title = [NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
        modal.content = [NSString stringWithFormat:@"%@",[dict objectForKey:@"content"]];
        modal.time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"reqtime"]];
        modal.isDeleted = NO;
        [self.dataArray addObject:modal];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    MessageCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MessageCenterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    MessageCenter *modal = self.dataArray[indexPath.row];
    [cell configWithModal:modal];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.dataArray removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCenter *modal = nil;
    if (indexPath.row < self.dataArray.count) {
        modal = self.dataArray[indexPath.row];
    }
    
    NSString *stateKey = nil;
    if (modal.isDeleted) {
        stateKey = @"delete";
    }else{
        stateKey = @"unDelete";
    }
    
    return [MessageCenterCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
        MessageCenterCell *cell = (MessageCenterCell *)sourceCell;
        [cell configWithModal:modal];
        
    } cache:^NSDictionary *{
        return @{kHYBCacheUniqueKey:modal.messageId, kHYBCacheStateKey:stateKey,
                 // 如果设置为YES，若有缓存，则更新缓存，否则直接计算并缓存
                 // 主要是对社交这种有动态评论等不同状态，高度也会不同的情况的处理
                 kHYBRecalculateForStateKey:@(NO)}; // 标识不用重新更新
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
- (void)editClick
{
    isDelete = !isDelete;
    NSMutableArray *copyArray = [self.dataArray copy];
    for (MessageCenter *modal in copyArray) {
        modal.isDeleted = isDelete;
    }
    self.dataArray = [NSMutableArray arrayWithArray:copyArray];
    [self.tableView reloadData];
    
    if (isDelete) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(editClick)];
        
        
    }else{
        BOOL isSelect = NO;
        NSMutableArray *indexs = [NSMutableArray array];
        NSMutableArray *objects = [NSMutableArray array];
        for (MessageCenter *modal in self.dataArray) {
            if (modal.isSel) {
                isSelect = YES;
                [indexs addObject:[NSIndexPath indexPathForRow:[self.dataArray indexOfObject:modal] inSection:0]];
                [objects addObject:modal];
            }
        }
        
        if (isSelect) {
            
            [self.dataArray removeObjectsInArray:objects];
            [self.tableView deleteRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editClick)];
        
    }
    
    
    
}

- (void)back
{
    if (isDelete) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确定取消编辑" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
