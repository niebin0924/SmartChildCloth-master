//
//  Baby.h
//  ChildCloth
//
//  Created by Kitty on 16/9/23.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Baby : NSObject <NSCoding>

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *childId;
@property (nonatomic,strong) NSString *eqId;
@property (nonatomic,strong) NSString *headUrl;

@end
