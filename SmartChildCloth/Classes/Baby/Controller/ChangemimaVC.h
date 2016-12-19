//
//  ChangemimaVC.h
//  ChildCloth
//
//  Created by cmfchina on 16/7/20.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangemimaVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *jiumima;
@property (weak, nonatomic) IBOutlet UITextField *xinmima;
@property (weak, nonatomic) IBOutlet UITextField *querenmima;

- (IBAction)queding:(id)sender;

@end
