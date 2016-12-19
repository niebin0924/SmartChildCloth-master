//
//  ColorTools.h
//  EnterpriseWeb
//
//  Created by 李小斌 on 14-5-28.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface ColorTools : NSObject

/** 颜色转换 IOS中十六进制的颜色转换为UIColor **/
+ (UIColor *) colorWithHexString: (NSString *)color;

@end
