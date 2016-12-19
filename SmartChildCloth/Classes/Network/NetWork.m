//
//  NetWork.m
//  jiutianguan
//
//  Created by 董仕林 on 15/11/24.
//  Copyright © 2015年 董仕林. All rights reserved.
//

#import "NetWork.h"
#import "SVProgressHUD.h"
#import "AFAppDotNetAPIClient.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIView+Toast.h"

@implementation NetWork

- (NSURLSessionDataTask *)httpNetWorkWithUrl:(NSString *)url WithBlock:(NSDictionary *)dic block:(NetBlock )block
{
    //检查网络
    if (![[Reachability reachabilityForInternetConnection] isReachable])
    {
        UIAlertView *alertViews = [[UIAlertView alloc] initWithTitle:@"该功能需要连接网络才能使用，请检查您的网络连接状态" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertViews show];
        return nil;
    }
    self.netBlock = block;
    
    // SVProgressHUDMaskType 介绍： 1. SVProgressHUDMaskTypeNone : 当提示显示的时间，用户仍然可以做其他操作，比如View 上面的输入等 2. SVProgressHUDMaskTypeClear : 用户不可以做其他操作 3. SVProgressHUDMaskTypeBlack :　用户不可以做其他操作，并且背景色是黑色 4. SVProgressHUDMaskTypeGradient : 用户不可以做其他操作，并且背景色是渐变的  SVProgressHUD 全部方法：
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    return [[AFAppDotNetAPIClient sharedClient] GET:url parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }success:^(NSURLSessionDataTask * __unused task, id JSON) {
        DLog(@"数据请求成功%@%@",url,dic);
        [SVProgressHUD dismiss];
        
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingAllowFragments error:nil];
         DLog(@"dic = %@",dic);
        
        if (self.netBlock) {
            
            self.netBlock(JSON, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        [SVProgressHUD dismiss];
        DLog(@"error = %@",error);
        [[UIApplication sharedApplication].keyWindow makeToast:@"服务器异常"];
        if (self.netBlock) {
            self.netBlock(nil, error);
        }
    }];

}


@end
