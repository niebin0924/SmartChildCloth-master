//
//  DropDownMenu.h
//  ChildCloth
//
//  Created by Kitty on 16/7/14.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectBlock)(NSString *title);

@interface DropDownMenu : UIView

@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,copy)NSString *textTitle;
@property (nonatomic,copy) selectBlock finishBlock;

@end
