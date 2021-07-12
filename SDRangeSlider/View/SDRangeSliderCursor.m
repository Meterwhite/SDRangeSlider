//
//  SDRangeSliderCursor.m
//  SDRangeSliderDemo
//
//  Created by MeterWhite on 2019/10/30.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import "SDRangeSliderCursor.h"

@interface SDRangeSliderCursor ()
@property (nonatomic) BOOL isImageSizeFill;
@end

@implementation SDRangeSliderCursor
{
    BOOL     _needRound;
    UIColor *_disableBackgroundColor;
    UIColor *_backgroundColor;
}
#define dMargin 4
#define dShadowRadius 2

#pragma mark - SDRangeSlider
+ (instancetype)defaultLeftButton:(CGFloat)itemSize
{
    SDRangeSliderCursor     *ret = [SDRangeSliderCursor buttonWithType:UIButtonTypeCustom];
    UIView  *view = [UIView new];
    CGFloat scale = [UIScreen mainScreen].scale;
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(0, 0, itemSize*scale, itemSize*scale);
    CALayer *layerShadow = [CALayer layer];
    layerShadow.frame = CGRectMake(2*dMargin*scale, dMargin*scale, (itemSize-dMargin*2)*scale, (itemSize-dMargin*2)*scale);
    layerShadow.backgroundColor = [UIColor clearColor].CGColor;
    layerShadow.cornerRadius = layerShadow.bounds.size.width/2;
    layerShadow.shadowRadius = dShadowRadius;
    layerShadow.shadowColor = [UIColor blackColor].CGColor;
    layerShadow.shadowOffset = CGSizeMake(0, 4);
    layerShadow.shadowOpacity=0.4;
    CALayer *layerBtn = [CALayer layer];
    layerBtn.backgroundColor = [UIColor whiteColor].CGColor;
    layerBtn.frame = layerShadow.bounds;
    layerBtn.masksToBounds = YES;
    layerBtn.cornerRadius = layerBtn.bounds.size.width/2;
    layerBtn.borderColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    layerBtn.borderWidth = 0.6;
    [layerShadow addSublayer:layerBtn];
    [view.layer addSublayer:layerShadow];
    //截图(screenshots)
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 3);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *buttonImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [ret setImage:buttonImg forState:UIControlStateNormal];
    [ret setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    return ret;
}

+ (instancetype)defaultRightButton:(CGFloat)itemSize
{
    SDRangeSliderCursor *ret = [SDRangeSliderCursor buttonWithType:UIButtonTypeCustom];
    UIView  *view = [UIView new];
    CGFloat scale = [UIScreen mainScreen].scale;
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(0, 0, itemSize*scale, itemSize*scale);
    CALayer *layerShadow = [CALayer layer];
    layerShadow.frame = CGRectMake(0 , dMargin*scale, (itemSize-dMargin*2)*scale, (itemSize-dMargin*2)*scale);
    layerShadow.backgroundColor = [UIColor clearColor].CGColor;
    layerShadow.cornerRadius = layerShadow.bounds.size.width/2;
    layerShadow.shadowRadius = dShadowRadius;
    layerShadow.shadowColor = [UIColor blackColor].CGColor;
    layerShadow.shadowOffset = CGSizeMake(0, 4);
    layerShadow.shadowOpacity=0.4;
    CALayer *layerBtn = [CALayer layer];
    layerBtn.backgroundColor = [UIColor whiteColor].CGColor;
    layerBtn.frame = layerShadow.bounds;
    layerBtn.masksToBounds = YES;
    layerBtn.cornerRadius = layerBtn.bounds.size.width/2;
    layerBtn.borderColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    layerBtn.borderWidth = 0.6;
    [layerShadow addSublayer:layerBtn];
    [view.layer addSublayer:layerShadow];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 3);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *buttonImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [ret setImage:buttonImg forState:UIControlStateNormal];
    [ret setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    return ret;
}

- (SDRangeSliderCursor * _Nonnull (^)(void))usingCustomStyle
{
    /// clear image
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];
    [self setImage:nil forState:UIControlStateDisabled];
    [self setImage:nil forState:UIControlStateSelected];
    if (@available(iOS 9.0, *)) {
        [self setImage:nil forState:UIControlStateFocused];
    }
    [self setImage:nil forState:UIControlStateApplication];
    [self setImage:nil forState:UIControlStateReserved];
    // clear background image
    [self setBackgroundImage:nil forState:UIControlStateNormal];
    [self setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self setBackgroundImage:nil forState:UIControlStateDisabled];
    [self setBackgroundImage:nil forState:UIControlStateSelected];
    if (@available(iOS 9.0, *)) {
        [self setBackgroundImage:nil forState:UIControlStateFocused];
    }
    [self setBackgroundImage:nil forState:UIControlStateApplication];
    [self setBackgroundImage:nil forState:UIControlStateReserved];
    [self setBackgroundColor:nil];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    // clear round corner
    [self.layer setCornerRadius:0];
    [self.layer setMasksToBounds:NO];
    [self.layer setBorderWidth:0];
    return ^id(){
        return self;
    };
}

- (SDRangeSliderCursor * _Nonnull (^)(UIColor * _Nonnull))usingBackgroundColor
{
    return ^id(UIColor* color){
        [self setBackgroundColor:color];
        return self;
    };
}

- (SDRangeSliderCursor * _Nonnull (^)(UIColor * _Nonnull))usingBorderColor
{
    return ^id(UIColor* color){
        [self.layer setBorderColor:color.CGColor];
        return self;
    };
}

- (SDRangeSliderCursor * _Nonnull (^)(CGFloat))usingBorderWidth
{
    return ^id(CGFloat w){
        [self.layer setBorderWidth:w];
        return self;
    };
}

- (SDRangeSliderCursor * _Nonnull (^)(void))usingImageLeft
{
    return ^id(){
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        return self;
    };
}

- (SDRangeSliderCursor * _Nonnull (^)(void))usingImageRight
{
    return ^id(){
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        return self;
    };
}

- (SDRangeSliderCursor * _Nonnull (^)(UIColor * _Nonnull))usingDisableBackgroundColor
{
    return ^id(UIColor *color){
        self->_backgroundColor = self.backgroundColor;
        self->_disableBackgroundColor = color;
        return self;
    };
}

- (void)update
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UIView
- (void)layoutSubviews
{
    [super layoutSubviews];
    if(_needRound) {
        self.layer.cornerRadius = self.bounds.size.height * 0.5;
    }
}

#pragma mark - UIButton
- (void)setEnabled:(BOOL)enabled
{
    BOOL oriEnable = self.isEnabled;
    [super setEnabled:enabled];
    if(!_disableBackgroundColor) {
        return;
    }
    /// Update background color.
    if(oriEnable) {
        _backgroundColor = self.backgroundColor;
    }
    [self setBackgroundColor: enabled ? _backgroundColor : _disableBackgroundColor];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    SDRangeSliderCursor *ret= [super buttonWithType:buttonType];
    ret->_isImageSizeFill   = NO;
    ret->_needRound         = NO;
    return ret;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect ret =  [super imageRectForContentRect:contentRect];
    if(_isImageSizeFill){
        return contentRect;
    }
    return ret;
}

#pragma mark - Setter & Getter
- (SDRangeSliderCursor * _Nonnull (^)(void))usingImageFillSize
{
    self.isImageSizeFill = YES;
    [self update];
    return ^id(){
        return self;
    };
}

- (void)setIsImageSizeFill:(BOOL)isImageSizeFill
{
    _isImageSizeFill = isImageSizeFill;
    [self update];
}

- (SDRangeSliderCursor * _Nonnull (^)(void))usingRoundStyle
{
    self->_needRound = YES;
    [self.layer setCornerRadius:self.bounds.size.height];
    [self.layer setMasksToBounds:YES];
    [self update];
    return ^id(){
        return self;
    };
}

@end
