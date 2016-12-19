//
//  DeviceListCell.h
//  SmartChildCloth
//
//  Created by Kitty on 16/11/17.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceList.h"

@protocol EditClickDelegate <NSObject>

- (void)editClick:(NSIndexPath *)indexPath;

@end

@interface DeviceListCell : UITableViewCell

- (void)fillCellWithObject:(DeviceList *)modal;

@property (nonatomic,assign) id<EditClickDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexpath;

@end
