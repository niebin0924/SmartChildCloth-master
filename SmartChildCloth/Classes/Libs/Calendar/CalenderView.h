//
//  CalenderView.h
//  日历表
//
//  Created by apple on 16/6/14.
//  Copyright © 2016年 雷晏. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CalenderView;

@protocol CalenderViewDelegate <NSObject>

@optional
- (void)calenderView:(CalenderView *)calenderView SelectItem:(NSIndexPath *)indexPath WithDate:(NSDate *)date;

@end

@interface CalenderView : UIView

@property (nonatomic,assign) id<CalenderViewDelegate>delegate;

@end
