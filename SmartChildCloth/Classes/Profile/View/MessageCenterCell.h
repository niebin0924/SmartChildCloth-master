//
//  MessageCenterCell.h
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageCenter;

typedef void(^SelectBlock)(UIButton *);

@interface MessageCenterCell : UITableViewCell

@property (nonatomic,strong) MessageCenter *modal;
@property (nonatomic,assign) SelectBlock selBlock;

- (void)configWithModal:(MessageCenter *)modal;

@end
