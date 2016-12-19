//
//  UserInfo.h
//  ChildCloth
//
//  Created by Kitty on 16/7/8.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *birthday;
@property (nonatomic,copy) NSString *heightString;
@property (nonatomic,copy) NSString *weightString;

@property (nonatomic,copy) NSString *token;
// 是否绑定app
@property (nonatomic,assign) BOOL isBindApp;

@end
