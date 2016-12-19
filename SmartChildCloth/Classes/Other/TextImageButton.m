//
//  TextImageButton.m
//  intellectualClose
//
//  Created by Kitty on 16/6/27.
//  Copyright © 2016年 dongshilin. All rights reserved.
//

#import "TextImageButton.h"
#import "Masonry.h"

@interface TextImageButton()

@end


@implementation TextImageButton


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.contentMode = UIViewContentModeCenter;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.highlighted = NO;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width, self.frame.size.height);
//    self.imageView.frame = CGRectMake(self.titleLabel.frame.size.width + 3, 0, self.frame.size.width - self.titleLabel.frame.size.width - 3, 10);
    self.imageView.frame = CGRectMake(self.titleLabel.frame.size.width + 3, 0, 13, 10);
    self.imageView.center = CGPointMake(self.imageView.center.x, self.center.y);
    
}

@end
