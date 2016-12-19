//
//  BadyTableViewCell.h
//  ChildCloth
//
//  Created by cmfchina on 16/7/18.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *photoImge;
@property (weak, nonatomic) IBOutlet UILabel *name;

- (IBAction)photo:(id)sender;

@end
