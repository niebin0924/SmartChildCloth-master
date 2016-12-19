//
//  Baby.m
//  ChildCloth
//
//  Created by Kitty on 16/9/23.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "Baby.h"

@implementation Baby

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.childId forKey:@"childId"];
    [aCoder encodeObject:self.eqId forKey:@"eqId"];
    [aCoder encodeObject:self.headUrl forKey:@"headUrl"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.childId = [aDecoder decodeObjectForKey:@"childId"];
        self.eqId = [aDecoder decodeObjectForKey:@"eqId"];
        self.headUrl = [aDecoder decodeObjectForKey:@"headUrl"];
    }
    
    return self;
}

@end
