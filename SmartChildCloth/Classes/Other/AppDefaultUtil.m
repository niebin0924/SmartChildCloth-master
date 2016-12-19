//
//  AppDefaultUtil.m
//  ChildCloth
//
//  Created by Kitty on 16/8/19.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "AppDefaultUtil.h"

#define KEY_FIRSTLANUCH @"FirstLaunch"

#define KEY_CLIENTID    @"ClientId"

#define KEY_ACCOUNT     @"Account"

#define KEY_CHILDS      @"Childs"

#define KEY_HEARD_IMAGE @"HeadImage" //头像
#define KEY_NICKNAME    @"NickName"
#define KEY_CHILDID     @"ChildId"
#define KEY_EQID        @"EqId"

#define KEY_ISBINDAPP   @"BindApp"

#define KEY_TOKEN       @"Token"


#define KEY_BIRTHDAY    @"birthday"
#define KEY_HEIGHT      @"height"
#define KEY_WEIGHT      @"weight"
#define KEY_GENDER      @"gender"


@implementation AppDefaultUtil

+ (instancetype)sharedInstance {
    
    static AppDefaultUtil *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[AppDefaultUtil alloc] init];
        
    });
    
    return _sharedClient;
}

- (void)setFirstLanuch:(BOOL)isFirst
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isFirst forKey:KEY_FIRSTLANUCH];
    [defaults synchronize];
}

- (BOOL)getFirstLanuch
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:KEY_FIRSTLANUCH];
}

- (void)setClientId:(NSString *)clientId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:clientId forKey:KEY_CLIENTID];
    [defaults synchronize];
}

- (NSString *)getClientId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_CLIENTID];
}

- (void)setAccount:(NSString *)account
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account forKey:KEY_ACCOUNT];
    [defaults synchronize];
}

- (NSString *)getAccount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_ACCOUNT];
}

- (void)setChilds:(NSArray *)childs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:childs forKey:KEY_CHILDS];
    [defaults synchronize];
}

- (NSArray *)getChilds
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults arrayForKey:KEY_CHILDS];
}

- (void)setHeadImageUrl:(NSString *)headUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:headUrl forKey:KEY_HEARD_IMAGE];
    [defaults synchronize];
}

- (NSString *)getHeadImageUrl
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_HEARD_IMAGE];
}

- (void)setBindApp:(BOOL)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:KEY_ISBINDAPP];
    [defaults synchronize];
}

- (BOOL)isBindApp
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:KEY_ISBINDAPP];
}

// 存储加密后的token
- (void)setToken:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:KEY_TOKEN];
    [defaults synchronize];
}

- (NSString *)getToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_TOKEN];
}

- (void)setChildId:(NSString *)childId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:childId forKey:KEY_CHILDID];
    [defaults synchronize];
}

- (NSString *)getChildId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_CHILDID];
}

- (void)setEqId:(NSString *)eqId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:eqId forKey:KEY_EQID];
    [defaults synchronize];
}

- (NSString *)getEqId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_EQID];
}

- (void)setNickName:(NSString *)nickname
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nickname forKey:KEY_NICKNAME];
    [defaults synchronize];
}

- (NSString *)getNickName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_NICKNAME];
}

- (void)setBirthday:(NSString *)birthday
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:birthday forKey:KEY_BIRTHDAY];
    [defaults synchronize];
}

- (NSString *)getBirthday
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_BIRTHDAY];
}

- (void)setHeight:(NSString *)height
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:height forKey:KEY_HEIGHT];
    [defaults synchronize];
}

- (NSString *)getHeight
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_HEIGHT];
}

- (void)setWeight:(NSString *)weight
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:weight forKey:KEY_WEIGHT];
    [defaults synchronize];
}

- (NSString *)getWeight
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:KEY_WEIGHT];
}

- (void)setGender:(NSInteger)gender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:gender forKey:KEY_GENDER];
    [defaults synchronize];
}

- (NSInteger)getGender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:KEY_GENDER];
}

@end
