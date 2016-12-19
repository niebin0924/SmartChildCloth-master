//
//  WeightViewController.h
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightViewController : UIViewController

@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,assign) NSInteger gender; // 0男1女
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *height;
@property (nonatomic,strong) NSString *weight;
@property (nonatomic,strong) UIImage *picImage;

@end
