//
//  SDRangeSliderCursor.h
//  SDRangeSliderDemo
//
//  Created by MeterWhite on 2019/10/30.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import "SDRangeSliderDefines.h"
#import <UIKit/UIKit.h>

@interface SDRangeSliderCursor : UIButton

/// 强制布局 Force layout
- (void)update;

#pragma mark - Default
+ (nonnull instancetype)defaultLeftButton:(CGFloat)itemSize;
+ (nonnull instancetype)defaultRightButton:(CGFloat)itemSize;

#pragma mark - Custom style
/// 使用UIButton的初始设置 Initial setting of UIButton
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingCustomStyle)(void);
#pragma mark - Using image
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingImageFillSize)(void);
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingImageLeft)(void);
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingImageRight)(void);
#pragma mark - Using background color
/// 圆型
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingRoundStyle)(void);
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingBackgroundColor)(UIColor*_Nonnull color);
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingBorderColor)(UIColor*_Nonnull color);
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingBorderWidth)(CGFloat w);
/// Background color dispalyed in disable state(UIControlStateDisabled).
@property SDSliderLinkFunc SDRangeSliderCursor*_Nonnull(^usingDisableBackgroundColor)(UIColor *_Nonnull color);
@end
