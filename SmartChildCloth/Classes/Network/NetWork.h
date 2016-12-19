//
//  NetWork.h
//  jiutianguan
//
//  Created by 董仕林 on 15/11/24.
//  Copyright © 2015年 董仕林. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetBlock) (NSData *data,NSError *error);

@interface NetWork : NSObject

@property(nonatomic,strong) NetBlock netBlock;

- (NSURLSessionDataTask *)httpNetWorkWithUrl:(NSString *)url WithBlock:(NSDictionary *)dic block:(NetBlock )block;

//- (NSURLSessionDataTask *)httpNetWorkWithBlock:(NSDictionary *)dic block:(NetBlock ) block ;

@end
