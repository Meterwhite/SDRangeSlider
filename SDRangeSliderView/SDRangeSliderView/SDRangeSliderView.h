//
//  SDRangeSliderView.h
//  SDRangeSliderView
//
//  Created by NOVO on 2018/1/3.
//  Copyright © 2018年 NOVO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDRangeSliderViewDelegate <NSObject>
- (void)sliderValueDidChangedOfLeft:(double)left right:(double)right;
@end

/**
 *双滑块选择器(Double slider selector)
 *可设置制精度和取值位置，可设置控件样式(Can set the precision and value position, can set control style)
 *便利的使用性(Ease to use)
 *注意(Attention)：
 *控件高度固定为游标按钮宽度(itemSize)，且不可更改;(The control height is fixed as the cursor button width (itemSize) and cannot be changed.)
 *使用KVC可以完全控制游标接触时的刻度差值:[slider setValue:@(5) forKey:@"_valueMargin"];(using KVC can completely control the scale difference when the cursor is in contact:[slider setValue:@(5) forKey:@"valueMargin"])
 */
@interface SDRangeSliderView : UIView

/** 游标按钮宽度，默认值30(Cursor button width, default value 30) */
@property (nonatomic,assign) CGFloat itemSize;

/**
 当游标移动的时候触发的回调(A callback that is triggered when the cursor moves)
 */
- (void)eventValueDidChanged:(void(^)(double left, double right))block;

/**
 *用户自定义游标按钮样式(User custom cursor button style)
 *控件内两个按钮使用分别使用内容右对齐和左对齐的方式(The two buttons in the control use the right and left alignment of the content)
 */
- (void)customUIUsingBlock:(void(^)(UIButton* leftCursor,UIButton* rightCursor))block;

/** 最小刻度，默认1.0(Minimum scale, default 1.0) */
@property (nonatomic,assign) double minimumSize;
/** 最小值，默认0.0；使用[update]展示变化(default is 0.0;Use [update] to show changes) */
@property (nonatomic,assign) double minValue;
/** 最大值，默认100.0；使用[update]展示变化(default is 100.0;Use [update] to show changes) */
@property (nonatomic,assign) double maxValue;

/** 左游标按钮值(Left cursor button value) */
@property (nonatomic,assign) double leftValue;
/** 右游标按钮初始值(Right cursor button value) */
@property (nonatomic,assign) double rightValue;

/** 线高，默认值2(Line height, default value 2) */
@property (nonatomic,assign) CGFloat lineHeight;


/** 更新UI */
- (void)update;
/**
 使用游标的顶部取值，两个游标可以取到相等的值；默认值；(Using the top value of the cursor, two cursors can be obtained equal value; The default value;)
 */
- (void)usingValueAtFront;
/**
 使用游标的中心取值，两个游标不能取到相等的值(With the center of the cursor, the two cursors cannot be equal to each other)
 */
- (void)usingValueUnequal;

/**
 调整线条两端的起始偏移,负数时向两边延伸(Adjust the starting offset at both ends of the line and extend it to both sides when negative)
 */
@property (nonatomic,assign) double offsetOfAdjustLineStart;

/**
 调整线条终端的偏移,正数时向中间延伸(Adjust the offset of the end of the line and extend the positive to the middle)
 */
@property (nonatomic,assign) double offsetOfAdjustLineEnd;



@property (nonatomic,strong) UIColor* lineColor;
@property (nonatomic,strong) UIColor* highlightLineColor;

@property (nonatomic,weak) id<SDRangeSliderViewDelegate> delegate;
@end
