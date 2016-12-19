//
//  AppDefaultUtil.h
//  ChildCloth
//
//  Created by Kitty on 16/8/19.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDefaultUtil : NSObject


/**
 单例模式，实例化对象
 */
+ (instancetype)sharedInstance;

- (void)setFirstLanuch:(BOOL)isFirst;
- (BOOL)getFirstLanuch;

- (void)setClientId:(NSString *)clientId;
- (NSString *)getClientId;

- (void)setAccount:(NSString *)account;
- (NSString *)getAccount;

- (void)setChilds:(NSArray *)childs;
- (NSArray *)getChilds;

// 保存当前图像
- (void)setHeadImageUrl:(NSString *)headUrl;
- (NSString *)getHeadImageUrl;
// 保存当前childId
- (void)setChildId:(NSString *)childId;
- (NSString *)getChildId;
// 保存当前eqId
- (void)setEqId:(NSString *)eqId;
- (NSString *)getEqId;
// 保存当前昵称
- (void)setNickName:(NSString *)nickname;
- (NSString *)getNickName;

// 设置是否绑定设备
-(void) setBindApp:(BOOL)value;
// 获取是否绑定设备
-(BOOL) isBindApp;

// 设置token
- (void)setToken:(NSString *)token;
// 获取token
- (NSString *)getToken;

/*
- (void)setBirthday:(NSString *)birthday;
- (NSString *)getBirthday;

- (void)setHeight:(NSString *)height;
- (NSString *)getHeight;

- (void)setWeight:(NSString *)weight;
- (NSString *)getWeight;
*/
- (void)setGender:(NSInteger)gender;
- (NSInteger)getGender;

@end
