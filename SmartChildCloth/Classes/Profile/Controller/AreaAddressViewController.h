//
//  AreaAddressViewController.h
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMapViewController.h"

@protocol SafeAddressDelegate <NSObject>

- (void)updateAddress:(NSString *)addresss;

@end

@interface AreaAddressViewController : BaseMapViewController

@property (nonatomic,strong) NSString *titleString;
@property (nonatomic,strong) NSString *type; // 1:学校 2:家-小区
@property (nonatomic,weak) id<SafeAddressDelegate>delegate;

@end
