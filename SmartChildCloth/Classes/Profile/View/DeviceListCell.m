//
//  DeviceListCell.m
//  SmartChildCloth
//
//  Created by Kitty on 16/11/17.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "DeviceListCell.h"

@interface DeviceListCell ()

@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *deviceNoLabel;
@property (nonatomic,strong) UIButton *editBtn;

@end

@implementation DeviceListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.headImageView = ({
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 30.f;
            imageView;
        });
        [self.contentView addSubview:self.headImageView];
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.size.mas_equalTo(CGSizeMake(60, 60));
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        self.nameLabel = ({
        
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:17.f];
            label;
        });
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.headImageView.mas_right).offset(10);
            make.top.equalTo(self.headImageView.mas_top);
            make.height.equalTo(@21);
            
        }];
        
        self.deviceNoLabel = ({
            
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:15.f];
            label;
        });
        [self.contentView addSubview:self.deviceNoLabel];
        [self.deviceNoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.headImageView.mas_right).offset(10);
            make.height.equalTo(@21);
            make.bottom.equalTo(self.headImageView.mas_bottom);
        }];
        
        self.editBtn = ({
            
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
            [button setTitle:@"解除" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14.f];
            button.backgroundColor = [UIColor lightGrayColor];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 20.f;
            [button addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self.contentView addSubview:self.editBtn];
        [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
        }];
        
    }
    
    
    return self;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//}

- (void)editClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(editClick:)]) {
        [self.delegate editClick:self.indexpath];
    }
}

- (void)fillCellWithObject:(DeviceList *)modal
{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:modal.iconName] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    self.nameLabel.text = modal.name;
    self.deviceNoLabel.text = modal.deviceNo;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
