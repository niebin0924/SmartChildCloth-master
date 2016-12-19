//
//  QuanZiTableViewCell.m
//  ChildCloth
//
//  Created by dongshilin on 16/7/14.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "QuanZiTableViewCell.h"

@interface QuanZiTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;



@end

@implementation QuanZiTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)fillCellWithModal:(Poster *)modal
{
    self.circleId = modal.circleId;
    self.collected = modal.collected;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:modal.headUrl] placeholderImage:[UIImage imageNamed:@"default_headpic"]];
    self.nameLabel.text = modal.posterName;
    self.timeLabel.text = modal.dateTime;
    self.titleLabel.text = modal.title;
    self.contentLabel.text = modal.content;
}

- (IBAction)popSheetBtnClick:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(popSheetDelegate:)]) {
        [self.delegate popSheetDelegate:self];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
