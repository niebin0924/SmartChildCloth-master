//
//  SwitchCell.h
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SwitchChangeBlock)(UISwitch *);

@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;

@property (nonatomic,assign) SwitchChangeBlock block;

- (void)valueChange:(SwitchChangeBlock)block;

@end
