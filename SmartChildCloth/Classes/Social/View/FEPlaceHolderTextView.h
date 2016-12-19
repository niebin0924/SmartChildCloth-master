//
//  FEPlaceHolderTextView.h
//  PRJ_YDAC
//
//  Created by 黄隆 on 16/4/25.
//  Copyright © 2016年 cn.com.sxit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEPlaceHolderTextView : UITextView
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;
@end
