//
//  MHTransformCorrdinate.h
//  定位服务
//
//  Created by hcl on 16/3/11.
//  Copyright © 2016年 hcl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MHTransformCorrdinate : NSObject

// 百度坐标转谷歌坐标
+ (CLLocationCoordinate2D)getGoogleLocFromBaiduLocLat:(CGFloat)fBaiduLat lng:(CGFloat)fBaiduLng;
+ (void)transformatBDLat:(CGFloat)fBDLat BDLng:(CGFloat)fBDLng toGoogleLat:(CGFloat *)pfGoogleLat googleLng:(CGFloat *)pfGoogleLng;

// 谷歌坐标转百度坐标
+ (CLLocationCoordinate2D)getBaiduLocFromGoogleLocLat:(CGFloat)fGoogleLat lng:(CGFloat)fGoogleLng;

// GPS坐标转谷歌坐标
+ (CLLocationCoordinate2D)GPSLocToGoogleLoc:(CLLocationCoordinate2D)objGPSLoc;

@end
