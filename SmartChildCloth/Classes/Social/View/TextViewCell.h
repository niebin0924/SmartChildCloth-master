//
//  TextViewCell.h
//  TextViewCell
//
//  Created by elink on 16/8/5.
//  Copyright © 2016年 elink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEPlaceHolderTextView.h"

@protocol TextViewCellDelegate <NSObject>

- (void)textViewCellDidChangeText:(NSString*)text withIndexPath:(NSIndexPath*)indexPath;

@end

@interface TextViewCell : UITableViewCell

@property(nonatomic,assign)id<TextViewCellDelegate>delegate;
@property(nonatomic,strong)FEPlaceHolderTextView *textView;

-(void)setTitle:(NSString*)title withContent:(NSString*)content withIndexPath:(NSIndexPath*)indexPath;

@end


