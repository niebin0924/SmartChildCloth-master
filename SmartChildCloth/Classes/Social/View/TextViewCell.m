//
//  TextViewCell.m
//  TextViewCell
//
//  Created by elink on 16/8/5.
//  Copyright © 2016年 elink. All rights reserved.
//

#import "TextViewCell.h"

@interface TextViewCell ()<UITextViewDelegate>
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)NSIndexPath *indexPath;
@end

@implementation TextViewCell

/*
-(UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.mas_top);
            make.left.mas_equalTo(self.mas_left).offset(20.0f);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
    
    return _titleLab;
}
 */

-(UITextView *)textView
{
    if (!_textView)
    {
        _textView = [[FEPlaceHolderTextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.textColor = [UIColor blackColor];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.delegate = self;
        _textView.scrollEnabled = NO;
        _textView.placeholder = @"输入帖子标题";
        [self.contentView addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(5);
            make.left.mas_equalTo(@10);
            make.width.mas_equalTo(self.mas_width).offset(-20);
            make.height.mas_equalTo(self.mas_height).offset(-10);
        }];
        
    }
    
    return _textView;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(textViewCellDidChangeText:withIndexPath:)]) {
        
        [self.delegate textViewCellDidChangeText:textView.text withIndexPath:self.indexPath];
    }
}

-(void)setTitle:(NSString*)title withContent:(NSString*)content withIndexPath:(NSIndexPath*)indexPath
{
    self.titleLab.text = title;
    
    self.textView.text = content;
    
    self.indexPath = indexPath;
}

@end
