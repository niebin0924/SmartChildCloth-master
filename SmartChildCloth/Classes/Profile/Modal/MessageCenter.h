//
//  MessageCenter.h
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageCenter : NSObject

@property (nonatomic,copy) NSString *messageId;
/** 是否已读 */
@property (nonatomic,assign) BOOL isRead;
/** 是否删除状态 */
@property (nonatomic,assign) BOOL isDeleted;
/** 是否选中状态 */
@property (nonatomic,assign) BOOL isSel;
/** 标题 */
@property (nonatomic,copy) NSString *title;
/** 消息内容 */
@property (nonatomic,copy) NSString *content;
/** 消息时间 */
@property (nonatomic,copy) NSString *time;

@end
