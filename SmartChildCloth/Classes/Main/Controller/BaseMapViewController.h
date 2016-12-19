//
//  BaseMapViewController.h
//  ChildCloth
//
//  Created by Kitty on 16/7/12.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseMapViewController : UIViewController <MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapLocationManager *locationManager;

/**
 *  hook,子类覆盖它,实现想要在viewDidAppear中执行一次的方法,搜索中有用到
 */
- (void)hookAction;

- (NSString *)getApplicationName;
- (NSString *)getApplicationScheme;

@end
