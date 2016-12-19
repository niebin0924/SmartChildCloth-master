//
//  CustomCalloutView.m
//  Category_demo2D
//
//  Created by xiaoming han on 13-5-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CustomCalloutView.h"
#import <QuartzCore/QuartzCore.h>

#define kArrorHeight    10

@interface CustomCalloutView ()

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *placeLabel;
@property (nonatomic,strong) UILabel *descLabel;

@end

@implementation CustomCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, self.frame.size.width-20, 20)];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.timeLabel];
    
    self.placeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.timeLabel.frame), self.frame.size.width-20, 20)];
    self.placeLabel.numberOfLines = 0;
    self.placeLabel.font = [UIFont systemFontOfSize:14];
    self.placeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.placeLabel];
    
    self.descLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.placeLabel.frame), self.frame.size.width-20, 20)];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.descLabel];
}

- (void)setTime:(NSString *)time
{
    self.timeLabel.text = time;
}

- (void)setPlace:(NSString *)place
{
    self.placeLabel.text = place;
    
    CGSize size = [place boundingRectWithSize:CGSizeMake(self.frame.size.width-20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]} context:nil].size;
    
    CGRect rect = self.placeLabel.frame;
    rect.size.height = size.height;
    self.placeLabel.frame = rect;
    
    self.descLabel.frame = CGRectMake(10, CGRectGetMaxY(self.placeLabel.frame), self.frame.size.width-20, 20);
}

- (void)setDesc:(NSString *)desc
{
    self.descLabel.text = desc;
}

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect
{
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, KColor.CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
    
}

- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
