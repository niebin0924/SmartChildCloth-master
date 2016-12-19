//
//  NSString+UserInfo.h
//  SP2P_6.1
//
//  Created by 李小斌 on 14-10-9.
//  Copyright (c) 2014年 EIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UserInfo)

//+(NSString *)base64Md5:(NSString *)password;

// 把手机号第4-7位变成星号
+(NSString *)phoneNumToAsterisk:(NSString*)phoneNum;

// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString;

//获取设备表示符
//+(NSString *)getVendorString;

/*
 * 给字符串md5加密
 */
- (NSString*)md5;

// 把手机号第5-14位变成星号
+(NSString *)idCardToAsterisk:(NSString *)idCardNum;

// 判断是否是身份证号码
+(BOOL)validateIdCard:(NSString *)idCard;

// 邮箱验证
+(BOOL)validateEmail:(NSString *)email;

// 手机号码验证
+(BOOL)validateMobile:(NSString *)mobile;

//判断密码是否为纯数字或者字母
+ (BOOL) validateSecret:(NSString *)mobile;

//+(NSString *)selectedDB:(NSString *)num;
//+(NSString *)selectedBizScope:(NSString *)bizScope;

//+(NSString *)selectedBank:(NSString *)bankType;
//格式化银行卡号码
//+(NSString *)formatBank:(NSString *)bankType;

@end
