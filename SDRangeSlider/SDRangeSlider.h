//
//  SDRangeSlider.h
//  SDRangeSlider
//
//  Created by Meterwhite on 2018/1/3.
//  Copyright © 2018年 Meterwhite. All rights reserved.
//

#import "SDRangeSliderCursor.h"
#import "SDRangeSliderDefines.h"
#import "SDRangeSliderValues.h"
#import "SDRangeSliderPoints.h"

@class RACSubject, SDRangeSlider;
#pragma mark ------ SDRangeSliderViewDelegate
@protocol SDRangeSliderViewDelegate <NSObject>
- (void)rangeSliderValueDidChangedTo:(nonnull SDRangeSliderValues *)values;
- (void)rangeSliderCursorOriginDidChangedTo:(nonnull SDRangeSliderPoints *)points;
@end

#pragma mark ------ SDRangeSlider
/**
 *  iOS系统样式双滑块选择器(Range slider selector.Like iOS system style)
 *  Using frame layout or autolayout.
 *  注意(Note)：
 *  1.游标按钮尺寸跟随控件高度;(The cursor button size follows the height of the control)
 *  2.XIB可直接设置值;（You can set the value directly in XIB）
 *  3.提供链式编程的语法糖;(Syntactic sugar for chain programming)
 */
@interface SDRangeSlider : UIView
#pragma mark ---- 回调 Call back
#pragma mark a.代理（Delegate）
@property (nonatomic,weak,nullable) id<SDRangeSliderViewDelegate> delegate;
#pragma mark b.回调 (call back)
/**
 游标值改变时的回调(A callback that is triggered when the cursor moves)
 */
- (nonnull instancetype)eventValueDidChanged:(void(^_Nonnull)(SDRangeSliderValues *_Nonnull values))block;

/// 游标位置变化时的回调(Callback when the cursor position changes)
/// @param view nil时为参考本控件的坐标系
- (nonnull instancetype)eventCursorOriginDidChanged:(void(^_Nonnull)(SDRangeSliderPoints *_Nonnull points))block
                               converToView:(nullable __weak UIView*)view;
#pragma mark c.响应式 ReactiveCocoa
/**
    [slider.signalRangeSliderValueDidChanged subscribeNext:^(SDRangeSliderValues *values) {
        codeing...
    }];
 */
@property (nullable,nonatomic,strong) RACSubject *signalRangeSliderValueDidChanged;
/**
   [slider.signalRangeSliderCursorOriginDidChanged subscribeNext:^(SDRangeSliderPoints *values) {
       codeing...
   }];
*/
@property (nullable,nonatomic,strong) RACSubject  *signalRangeSliderCursorOriginDidChanged;

#pragma mark ---- 按钮(UIButton)
@property (nonnull,nonatomic) SDRangeSliderCursor* leftCursor;
@property (nonnull,nonatomic) SDRangeSliderCursor* rightCursor;
/** 最小刻度，默认1.0(Minimum scale, default 1.0) */
@property (nonatomic) IBInspectable double minimumSize;
/** 最小值，默认0.0；(default is 0.0) */
@property (nonatomic,assign) IBInspectable double minValue;
/** 最大值，默认100.0；(default is 100.0) */
@property (nonatomic) IBInspectable double maxValue;
/** 左游标按钮值，对UI有效(Left cursor button value.) */
@property (nonatomic) IBInspectable double leftValue;
/** 右游标按钮值，对UI有效(Right cursor button value) */
@property (nonatomic) IBInspectable double rightValue;

#pragma mark - 线条 Line
/** 有效线条的可用颜色(Valid line color) */
@property (nonnull,nonatomic) UIColor *highlightLineColor;
@property (nonnull,nonatomic) UIColor *disableHighlightLineColor;
/** 无效线条的可用颜色(Invalid line color) */
@property (nonnull,nonatomic) UIColor *lineColor;
@property (nonnull,nonatomic) UIColor *disableLineColor;
/** 线条高，默认值2(Line height, default value 2) */
@property (nonatomic) CGFloat lineHeight;
/**
 调整线条两端的起始偏移,负数时向两边延伸(Adjust the starting offset at both ends of the line and extend it to both sides when negative)
 */
@property (nonatomic) double offsetOfAdjustLineStart;
/**
 调整线条终端的偏移,正数时向中间延伸(Adjust the offset of the end of the line and extend the positive to the middle)
 */
@property (nonatomic) double offsetOfAdjustLineEnd;

#pragma mark ---- 用户偏好 Custom preference
/** 游标按钮尺寸跟随控件高度反之也会影响控件高度，可以不设置。(The size of the cursor button follows the height of the control and vice versa. Can not be set.) */
@property (nonatomic) CGFloat itemSize;
/// Default YES
@property (nonatomic,getter=isEnabled) BOOL enabled;
/**
 *用户自定义游标按钮样式(User custom cursor button style)
 *注意：控件内两个按钮使用默认分别使用内容右对齐和左对齐的方式(Note: The two buttons in the control use the right and left alignment of the content)
 */
- (nonnull instancetype)customButtonStyleUsingBlock:(void(^_Nonnull)(SDRangeSliderCursor*_Nonnull left,SDRangeSliderCursor*_Nonnull right))block;
/**
 使用游标的顶部取值，两个游标可以取到相等的值；默认值；(Using the top value of the cursor, two cursors can be obtained equal value; The default value;)
 */
//- (nonnull instancetype)usingValueAtFront;
//- (instancetype _Nonnull(^_Nonnull)(void))usingValueAtFront;
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingValueAtFront)(void);
/**
 使用游标的中心取值，两个游标不能取到相等的值(With the center of the cursor, the two cursors cannot be equal to each other)
 */
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingValueUnequal)(void);

#pragma mark 链式编程 Link code
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingMinimumSize)(double v);
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingMinValue)(double v);
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingMaxValue)(double v);
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingLineHeight)(CGFloat h);
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingLineColor)(UIColor*_Nonnull color);
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingHighlightLineColor)(UIColor*_Nonnull color);
/// Height 30
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingSystemSliderHeight)(void);
@property SDSliderLinkFunc SDRangeSlider *_Nonnull(^usingEnable)(BOOL enable);

#pragma mark - 其他
/// 强制布局 Force layout
- (nonnull SDRangeSlider*)update;
#pragma mark - Static
@property (nonnull,nonatomic,readonly,class) UIColor* defaultDisableColor;
@end
