//
//  QuanZiTableViewCell.h
//  ChildCloth
//
//  Created by dongshilin on 16/7/14.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Poster.h"
@class QuanZiTableViewCell;

@protocol popSheetDelegate <NSObject>

@optional
- (void)popSheetDelegate:(QuanZiTableViewCell *)cell;

@end

@interface QuanZiTableViewCell : UITableViewCell

@property (nonatomic,strong) NSString *circleId;
@property (nonatomic,assign) BOOL collected; // 是否收藏

@property (nonatomic,weak) id<popSheetDelegate>delegate;

- (void)fillCellWithModal:(Poster *)modal;


@end
