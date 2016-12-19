//
//  MessageCenterCell.m
//  ChildCloth
//
//  Created by Kitty on 16/7/7.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "MessageCenterCell.h"
#import "MessageCenter.h"

@interface MessageCenterCell ()

@property (nonatomic,strong) UIImageView *redDotImgView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIButton *editBtn;

@property (nonatomic,assign) BOOL isDel;

@end

@implementation MessageCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _redDotImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        _redDotImgView.backgroundColor = [UIColor redColor];
        _redDotImgView.layer.masksToBounds = YES;
        _redDotImgView.layer.cornerRadius = _redDotImgView.width * 0.5;
        [self.contentView addSubview:_redDotImgView];
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.preferredMaxLayoutWidth = SCREENWIDTH - 130;
        [self.contentView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor lightGrayColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.preferredMaxLayoutWidth = SCREENWIDTH - 90;
        [self.contentView addSubview:_contentLabel];
        
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeLabel];
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn setBackgroundImage:[UIImage imageNamed:@"icon_unchecked"] forState:UIControlStateNormal];
        [_editBtn setBackgroundImage:[UIImage imageNamed:@"icon_checked"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.hidden = YES;
        [self.contentView addSubview:_editBtn];
        
        self.hyb_lastViewInCell = _contentLabel;
        self.hyb_bottomOffsetToCell = 10;
        self.isDel = NO;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.redDotImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(10, 10));
        make.centerY.mas_equalTo(@0);
        make.left.mas_equalTo(@10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.redDotImgView.mas_right).offset(5);
        make.top.mas_equalTo(@10);
        make.size.mas_equalTo(CGSizeMake(SCREENWIDTH-130, 20));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.redDotImgView.mas_right).offset(5);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(5);
        make.right.mas_offset(@-65);
        make.width.mas_equalTo(SCREENWIDTH - 90);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@10);
        make.right.mas_equalTo(@-10);
        make.height.mas_equalTo(@20);
    }];
    
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.mas_equalTo(@(SCREENWIDTH));
    }];
}

- (void)configWithModal:(MessageCenter *)modal
{
    if (_modal != modal) {
        _modal = modal;
    }
    
    if (modal.isRead) {
        self.redDotImgView.hidden = YES;
    }else{
        self.redDotImgView.hidden = NO;
    }
    
    self.titleLabel.text = modal.title;
    self.contentLabel.text = modal.content;
    self.timeLabel.text = modal.time;
    
    if (modal.isDeleted != self.isDel) {
        self.isDel = modal.isDeleted;
        
        if (self.isDel) {
            
            self.editBtn.hidden = NO;
            [self.editBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(@(SCREENWIDTH-40));
            }];
            [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.right.mas_equalTo(@-50);
            }];
            
        }else{
            self.editBtn.hidden = YES;
            [self.editBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(@(SCREENWIDTH));
            }];
            [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(@-10);
            }];
        }
    }

    self.editBtn.selected = modal.isSel;
   
    
}

- (void)deleteClick:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    _modal.isSel = sender.isSelected;
    
    if (self.selBlock) {
        self.selBlock(sender);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
