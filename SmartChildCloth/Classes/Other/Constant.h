//
//  Constant.h
//  SmartChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define ViewHeight   self.view.frame.size.height

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RandomColor RGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256)) //随机色

//设置RGB颜色值
#define SETCOLOR(R,G,B,A)	[UIColor colorWithRed:(CGFloat)R/255 green:(CGFloat)G/255 blue:(CGFloat)B/255 alpha:A]

#define KColor  [ColorTools colorWithHexString:@"#4D97CD"]
// 每个View背景色值
#define KblackgroundColor  [ColorTools colorWithHexString:@"#F5F5F5"]
// 登录框 边框色值
#define KlayerBorder  [ColorTools colorWithHexString:@"#d9d9d9"]
//绿色颜色值
#define GreenColor [ColorTools colorWithHexString:@"#18b15f"]
//粉红颜色值
#define PinkColor  [ColorTools colorWithHexString:@"#e34f4f"]
//蓝色字体颜色值
#define BluewordColor  [ColorTools colorWithHexString:@"#436EEE"]
// button背景颜色
#define ButtonBgColor  [ColorTools colorWithHexString:@"#458BC7"]

// 应用程序托管
#define AppDelegateInstance	 ((AppDelegate*)([UIApplication sharedApplication].delegate))

#if DEBUG
    #define DLog(...) NSLog(__VA_ARGS__);
    #define DLog_METHOD NSLog(@"%s", __func__)
    #define DLogERROR(...) NSLog(@"%@传入数据有误",__VA_ARGS__)
#else
    #define DLog(format,...)
#endif

#define GaoDeAPIKey @"52d5779ebe45a725c4b435638b7579cf"

#define kGtAppId @"eIAe2gDl5q7VBbH4RRRFd6"
#define kGtAppKey @"sqHm5hvabk8XrnSgu5Bbh6"
#define kGtAppSecret @"Vpq62PFzoQ95MVCjySFwl7"


#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )480) < DBL_EPSILON )

#define IOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 9.0)
#define IOS8_10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 10.0)
#define IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)


#endif /* Constant_h */
