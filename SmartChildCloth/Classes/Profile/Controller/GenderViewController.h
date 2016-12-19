//
//  GenderViewController.h
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenderViewController : UIViewController

@property (nonatomic,strong) NSString *type;
@property (nonatomic,assign) NSInteger gender; // 0男1女
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) UIImage *picImage;

@end
