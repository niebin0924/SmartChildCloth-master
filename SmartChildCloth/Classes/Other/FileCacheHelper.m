//
//  FileCacheHelper.m
//  SmartChildCloth
//
//  Created by Kitty on 16/11/16.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "FileCacheHelper.h"

@implementation FileCacheHelper

+ (long long)fileSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size;
    }
    
    return 0;
}

+ (float)folderSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    cachePath = [cachePath stringByAppendingPathComponent:path];
    
    long long folderSize = 0;
    if ([fileManager fileExistsAtPath:cachePath]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:cachePath];
        for (NSString  *fileName in childerFiles) {
            NSString *fileAbsolutePath = [cachePath stringByAppendingPathComponent:fileName];
            long long size = [self fileSizeAtPath:fileAbsolutePath];
            folderSize += size;
        }
        
        //SDWebImage框架自身计算缓存的实现
        folderSize += [[SDImageCache sharedImageCache] getSize];
        return folderSize/1024.0/1024.0;
    }
    return 0;
}

+ (void)clearCache:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    cachePath = [cachePath stringByAppendingPathComponent:path];
    
    if ([fileManager fileExistsAtPath:cachePath]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:cachePath];
        for (NSString  *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *fileAbsolutePath = [cachePath stringByAppendingPathComponent:fileName];
            NSLog(@"fileAbsolutePath=%@",fileAbsolutePath);
            [fileManager removeItemAtPath:fileAbsolutePath error:nil];
        }
    }
    
    [[SDImageCache sharedImageCache] cleanDisk];
}

@end
