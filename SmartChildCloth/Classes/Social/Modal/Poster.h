//
//  Poster.h
//  ChildCloth
//
//  Created by Kitty on 16/10/20.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poster : NSObject

@property (nonatomic,strong) NSString *circleId; // 圈子ID
@property (nonatomic,strong) NSString *circlePicture;
@property (nonatomic,assign) BOOL collected; // 是否收藏
@property (nonatomic,assign) BOOL isHandpick;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *dateTime;
@property (nonatomic,strong) NSString *headUrl;
@property (nonatomic,strong) NSString *posterName; // 发帖人
@property (nonatomic,strong) NSString *posterId;
@property (nonatomic,assign) CGFloat  height;
@end
