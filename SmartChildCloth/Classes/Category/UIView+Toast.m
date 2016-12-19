//
//  UIView+Toast.m
//  ChildCloth
//
//  Created by Kitty on 16/7/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "UIView+Toast.h"
#import <objc/runtime.h>
#import "ColorTools.h"



static const CGFloat CSToastMaxWidth            = 0.8;
static const CGFloat CSToastMaxHeight           = 0.8;
static const CGFloat CSToastHorizontalPadding   = 10.0;
static const CGFloat CSToastVerticalPadding     = 10.0;
static const CGFloat CSToastCornerRadius        = 10.0;
static const CGFloat CSToastOpacity             = 0.8;
static const CGFloat CSToastFontSize            = 16.0;
//static const CGFloat CSToastMaxTitleLines       = 0;
static const CGFloat CSToastMaxMessageLines     = 0;
static const CGFloat CSToastFadeDuration        = 0.2;
static const CGFloat CSToastShadowOpacity       = 0.8;
static const CGFloat CSToastShadowRadius        = 6.0;
static const CGSize  CSToastShadowOffset        = { 4.0, 4.0 };
static const BOOL    CSToastDisplayShadow       = YES;
static const CGFloat CSToastDefaultDuration     = 1.0;



@implementation UIView (Toast)


#pragma mark - Toast Methods
- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:CSToastDefaultDuration];
}
- (void)makeToast:(NSString *)message duration:(CGFloat)interval {
    UIView *toast = [self viewForMessage:message];
    [self showToast:toast duration:interval];
}
- (void)showToast:(UIView *)toast duration:(CGFloat)interval{
    toast.center = [self centerPointForPosition:toast];
    toast.alpha = 0.0;
    [self addSubview:toast];
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:CSToastFadeDuration
                                               delay:interval
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              toast.alpha = 0.0;
                                          } completion:^(BOOL finished) {
                                              [toast removeFromSuperview];
                                          }];
                     }];
}
#pragma mark - Private Methods

- (CGPoint)centerPointForPosition:(UIView *)toast {
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - 20);
}

- (UIView *)viewForMessage:(NSString *)message{
    if(message == nil) return nil;
    UILabel *messageLabel = nil;
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = CSToastCornerRadius;
    if (CSToastDisplayShadow) {
        wrapperView.layer.shadowColor = [UIColor colorWithRed:99/255.f green:200/255.f blue:0 alpha:0.8f].CGColor;
        wrapperView.layer.shadowOpacity = CSToastShadowOpacity;
        wrapperView.layer.shadowRadius = CSToastShadowRadius;
        wrapperView.layer.shadowOffset = CSToastShadowOffset;
    }
    wrapperView.backgroundColor = [[ColorTools colorWithHexString:@"#f05228"]colorWithAlphaComponent:CSToastOpacity];
    messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines = CSToastMaxMessageLines;
    messageLabel.font = [UIFont systemFontOfSize:CSToastFontSize];
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.alpha = 1.0;
    messageLabel.text = message;
    CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * CSToastMaxWidth), self.bounds.size.height * CSToastMaxHeight);
    CGSize expectedSizeMessage = [message boundingRectWithSize:maxSizeMessage options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:CSToastFontSize]} context:nil].size;
    messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;
    messageWidth = messageLabel.bounds.size.width;
    messageHeight = messageLabel.bounds.size.height;
    messageLeft = CSToastHorizontalPadding;
    messageTop = CSToastVerticalPadding;
    wrapperView.frame = CGRectMake(0.0, 0.0, messageWidth+2*messageLeft, messageHeight+2*messageTop);
    messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
    [wrapperView addSubview:messageLabel];
    return wrapperView;
}


@end
