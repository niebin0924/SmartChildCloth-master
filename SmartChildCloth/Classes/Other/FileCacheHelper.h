//
//  FileCacheHelper.h
//  SmartChildCloth
//
//  Created by Kitty on 16/11/16.
//  Copyright © 2016年 Kitty. All rights reserved.
//

/*
 清除缓存两部分：
    1.自己缓存的数据
    2.使用SDWebImage第三方框架为我们缓存的图片文件
 */

#import <Foundation/Foundation.h>

@interface FileCacheHelper : NSObject


/**
 单个文件大小的计算
 
 @param path 文件路径
 @return 文件大小
 */
+ (long long)fileSizeAtPath:(NSString *)path;


/**
 文件夹大小的计算

 @param path 文件路径
 @return 文件大小
 */
+ (float)folderSizeAtPath:(NSString *)path;


/**
 清除缓存

 @param path 文件路径
 */
+ (void)clearCache:(NSString *)path;

@end
