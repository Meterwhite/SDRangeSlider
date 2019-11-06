//
//  SDRangeSlider.m
//  SDRangeSlider
//
//  Created by Meterwhite on 2018/1/3.
//  Copyright © 2018年 Meterwhite. All rights reserved.
//

#import "SDRangeSlider.h"
#import <objc/runtime.h>

static Class    _cls_racsubject;
static SEL      _sel_subject;
static SEL      _sel_sendNext;
static IMP      _imp_subject;
static IMP      _imp_sendNext;

@interface SDRangeSlider()
{
    __weak UIView*  _converReferencedView;
    CGPoint         _currentTouchCenter;
    BOOL            _isNeedUpdate;
    /**
     使用KVC可以完全控制游标接触时的刻度差值:[slider setValue:@(5) forKey:@"_valueMargin"](using KVC can completely control the scale difference when the cursor is in contact:[slider setValue:@(5) forKey:@"valueMargin"])
     */
    NSUInteger      _valueMargin;
}

@property (nonatomic,copy) void(^blockOfCursorOriginDidChanged)(SDRangeSliderPoints* points);
@property (nonatomic,copy) void(^blockOfValueDidChanged)(SDRangeSliderValues* values);
@property (nonatomic)           UIView*   backgroundLine;
@property (nonatomic,readonly)  CGFloat   itemRadius;
@property (nonatomic)           UIView*   leftLine;
@property (nonatomic)           UIView*   rightLine;
@end

@implementation SDRangeSlider
#pragma mark - runtime work
+ (UIColor *)defaultDisableColor
{
    static UIColor* _defaultDisableColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultDisableColor = [UIColor colorWithRed:209.0f/255.0f green:209.0f/255.0f blue:209.0f/255.0f alpha:1.0f];
    });
    return _defaultDisableColor;
}
+ (void)initialize
{
    if (self != [SDRangeSlider class]) return;
    
    _cls_racsubject     = NSClassFromString(@"RACSubject");
    _sel_subject        = NSSelectorFromString(@"subject");
    _sel_sendNext       = NSSelectorFromString(@"sendNext:");
    if(!_cls_racsubject || !_sel_subject || !_sel_sendNext) return;
    _imp_subject  = method_getImplementation(class_getClassMethod(_cls_racsubject, _sel_subject));
    _imp_sendNext = class_getMethodImplementation(_cls_racsubject, _sel_sendNext);
}

#pragma mark - Default value
/// Normal init
- (void)ninit
{
    _isNeedUpdate = NO;
    _itemSize   = self.frame.size.height;
    _offsetOfAdjustLineStart= 0.0;
    _offsetOfAdjustLineEnd  = 0.0;
    _maxValue   = 100.0;
    _minValue   = 0.0;
    _enabled    = YES;
    _lineHeight = 2;
    _minimumSize= 1;
    _rightValue = _maxValue;
    _leftValue  = _minValue;
    //指示色
    _lineColor = UIColor.lightGrayColor;
    _highlightLineColor = UIColor.systemBlueColor;
    _disableLineColor = SDRangeSlider.defaultDisableColor;
    _disableHighlightLineColor = SDRangeSlider.defaultDisableColor;
    //底部线条
    _backgroundLine = [UIView new];
    [_backgroundLine setBackgroundColor:_highlightLineColor];
    [self addSubview:_backgroundLine];
    //左线
    _leftLine = [UIView new];
    [_leftLine setBackgroundColor:_lineColor];
    [self addSubview:_leftLine];
    //右线
    _rightLine = [UIView new];
    [_rightLine setBackgroundColor:_lineColor];
    [self addSubview:_rightLine];
    //左游标按钮
    _leftCursor = [SDRangeSliderCursor defaultLeftButton:_itemSize];
    [self addSubview:_leftCursor];
    _leftCursor.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIPanGestureRecognizer* padLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(eventPan:)];
    [_leftCursor addGestureRecognizer:padLeft];
    //右游标按钮
    _rightCursor = [SDRangeSliderCursor defaultRightButton:_itemSize];
    [self addSubview:_rightCursor];
    _rightCursor.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //触摸
    UIPanGestureRecognizer* padRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(eventPan:)];
    [_rightCursor addGestureRecognizer:padRight];
    [self usingValueUnequal];
    //RAC
    if(_cls_racsubject){
        self.signalRangeSliderValueDidChanged = ((id(*)(id,SEL))_imp_subject)(_cls_racsubject, _sel_subject);
        self.signalRangeSliderCursorOriginDidChanged = ((id(*)(id,SEL))_imp_subject)(_cls_racsubject, _sel_subject);
    }
    [self linit];
}

/// Layout init
- (void)linit
{
    //底部线条
    CGFloat lineY = self.itemRadius-self.lineHeight/2;
    _backgroundLine.frame = CGRectMake(self.itemRadius, lineY , CGRectGetWidth(self.bounds)-self.itemSize , self.lineHeight);
    //左线
    _leftLine.frame = CGRectMake(self.itemRadius, lineY, 0, self.lineHeight);
    //右线
    _rightLine.frame = CGRectMake(self.controlWidth - self.itemRadius, lineY, 0, _lineHeight);
    //左游标
    _leftCursor.frame = CGRectMake(0, 0, _itemSize, _itemSize);
    //右游标
    _rightCursor.frame = CGRectMake(CGRectGetWidth(self.bounds)-self.itemSize, 0, self.itemSize, self.itemSize);
}

#pragma mark UIView
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self update];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(_isNeedUpdate){
        [self linit];
        [self setLeftValue:_leftValue sys:-1];
        [self setRightValue:_rightValue sys:-1];
        [self.leftCursor update];
        [self.rightCursor update];
        _isNeedUpdate = NO;
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self ninit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self ninit];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    _itemSize = frame.size.height;
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    _itemSize = bounds.size.height;
    [super setBounds:bounds];
}

#pragma mark - Setter & Getter
- (void)setMinimumSize:(double)minimumSize
{
    if(minimumSize <= 0) {
        return;
    }
    _minimumSize = minimumSize;
}

- (void)setItemSize:(CGFloat)itemSize
{
    CGRect rect = self.frame;
    rect.size.height = itemSize;
    [self setFrame:rect];
}

- (void)setOffsetOfAdjustLineStart:(double)offsetOfAdjustLineStart
{
    _offsetOfAdjustLineStart = offsetOfAdjustLineStart;
    CGRect frameOfBackgroundLine = self.backgroundLine.frame;
    frameOfBackgroundLine.origin.x += _offsetOfAdjustLineStart;
    self.backgroundLine.frame = frameOfBackgroundLine;
    frameOfBackgroundLine.size.width -= 2*_offsetOfAdjustLineStart;
    self.backgroundLine.frame = frameOfBackgroundLine;
    CGRect frameOfLeftLine = self.leftLine.frame;
    frameOfLeftLine.origin.x += _offsetOfAdjustLineStart;
    frameOfLeftLine.size.width -= _offsetOfAdjustLineStart;
    self.leftLine.frame = frameOfLeftLine;
    CGRect frameOfRightLine = self.rightLine.frame;
    frameOfRightLine.size.width -= _offsetOfAdjustLineStart;
    self.rightLine.frame = frameOfRightLine;
}

- (void)setOffsetOfAdjustLineEnd:(double)offsetOfAdjustLineEnd
{
    _offsetOfAdjustLineEnd = offsetOfAdjustLineEnd;
    CGRect frameOfLeftLine = self.leftLine.frame;
    frameOfLeftLine.size.width += _offsetOfAdjustLineEnd;
    self.leftLine.frame = frameOfLeftLine;
    CGRect frameOfRightLine = self.rightLine.frame;
    frameOfRightLine.origin.x -= _offsetOfAdjustLineEnd;
    frameOfRightLine.size.width += _offsetOfAdjustLineEnd;
    self.rightLine.frame = frameOfRightLine;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    if(!self.isEnabled) return;
    self.leftLine.backgroundColor = lineColor;
    self.rightLine.backgroundColor = lineColor;
}

- (void)setHighlightLineColor:(UIColor *)highlightLineColor
{
    _highlightLineColor = highlightLineColor;
    if(!self.isEnabled) return;
    self.backgroundLine.backgroundColor = highlightLineColor;
}

- (void)setDisableLineColor:(UIColor *)disableLineColor
{
    _disableLineColor = disableLineColor;
    if(self.isEnabled) return;
    self.leftLine.backgroundColor = disableLineColor;
    self.rightLine.backgroundColor = disableLineColor;
}

- (void)setDisableHighlightLineColor:(UIColor *)disableHighlightLineColor
{
    _disableHighlightLineColor = disableHighlightLineColor;
    if(self.isEnabled) return;
    self.backgroundLine.backgroundColor = disableHighlightLineColor;
}

- (CGFloat)itemRadius
{
    return self.itemSize/2;
}

- (CGFloat)controlWidth
{
    return self.frame.size.width;
}

#pragma mark 游标值 Value of cursor
- (void)setLeftValue:(double)left
{
    [self setLeftValue:left sys:YES];
}

- (void)setRightValue:(double)right
{
    [self setRightValue:right sys:YES];
}

- (void)setLeftValue:(double)left sys:(int)sys
{
    left = left<self.minValue?self.minValue:left;
    _leftValue = left;
    left -= _minValue;
    left /= _minimumSize;
    NSInteger totalOfCalibration = (self.maxValue - self.minValue)/self.minimumSize - _valueMargin;
    CGFloat widthOfCalibration = (self.controlWidth-self.itemSize*2)/totalOfCalibration;
    //按钮
    CGRect framOfButton= self.leftCursor.frame;
    framOfButton.origin.x = widthOfCalibration*left;//0-200
    self.leftCursor.frame = framOfButton;
    //线
    CGRect framOfLine = self.leftLine.frame;
    framOfLine.origin.x = self.itemRadius;
    framOfLine.size.width = widthOfCalibration*left + self.offsetOfAdjustLineEnd;
    if(self.offsetOfAdjustLineStart){
        framOfLine.origin.x += self.offsetOfAdjustLineStart;
        framOfLine.size.width -= self.offsetOfAdjustLineStart;
    }
    self.leftLine.frame = framOfLine;
    [self valueChanging:sys];
    [self cursorOriginChanging:sys];
}

- (void)setRightValue:(double)right sys:(int)sys
{
    right = right>self.maxValue?self.maxValue:right;
    _rightValue = right;
    right -= _minValue;
    right /= _minimumSize;
    right -= _valueMargin;
    NSInteger totalOfCalibration = (self.maxValue - self.minValue)/self.minimumSize - _valueMargin;
    CGFloat widthOfCalibration = (self.controlWidth-self.itemSize*2)/totalOfCalibration;//份长
    //按钮
    CGRect framOfButton= self.rightCursor.frame;
    framOfButton.origin.x = widthOfCalibration*right + self.itemSize;
    self.rightCursor.frame = framOfButton;
    //线
    CGRect framOfLine = self.rightLine.frame;
    framOfLine.origin.x = framOfButton.origin.x + self.itemRadius;
    framOfLine.size.width = self.controlWidth - widthOfCalibration*right -  self.itemSize*2;
    if(self.offsetOfAdjustLineEnd){
        framOfLine.origin.x -= self.offsetOfAdjustLineEnd;
        framOfLine.size.width += self.offsetOfAdjustLineEnd;
    }
    if(self.offsetOfAdjustLineStart){
        framOfLine.size.width -= self.offsetOfAdjustLineStart;
    }
    self.rightLine.frame = framOfLine;
    [self valueChanging:sys];
    [self cursorOriginChanging:sys];
}

#pragma mark 触摸事件 Touched event
- (void)eventPan:(UIPanGestureRecognizer*)pan
{
    if (!_enabled) return;
    CGPoint point = [pan translationInView:self];
    /// One finger handle
    if (pan.state == UIGestureRecognizerStateBegan) {
        _currentTouchCenter = pan.view.center;
        self.leftCursor.userInteractionEnabled = (pan.view == self.leftCursor);
        self.rightCursor.userInteractionEnabled = (pan.view == self.rightCursor);
    }else if(pan.state == UIGestureRecognizerStateEnded){
        self.leftCursor.userInteractionEnabled = YES;
        self.rightCursor.userInteractionEnabled = YES;
    }
    pan.view.center = CGPointMake(_currentTouchCenter.x + point.x, self.itemRadius);
    NSInteger totalOfCalibration = (self.maxValue - self.minValue)/self.minimumSize - _valueMargin;//刻度总份数
    CGFloat ineffectiveLength = self.itemSize*2;//无效的坐标系长度
    CGFloat widthOfCalibration = (self.controlWidth-ineffectiveLength)/totalOfCalibration;//一个刻度的宽
    /// 有效长度的坐标首先偏移，找整数刻度值；之后将这个整数刻度值和之前的偏移还原回坐标系统
    if (pan.state == UIGestureRecognizerStateEnded) {
        if(pan.view == self.leftCursor){
            CGFloat countOfCalibration = round((pan.view.center.x-self.itemRadius)/widthOfCalibration);
            pan.view.center = CGPointMake(countOfCalibration*widthOfCalibration+ineffectiveLength/4, pan.view.center.y);
        }else{
            CGFloat countOfCalibration = round((self.controlWidth - pan.view.center.x-self.itemRadius)/widthOfCalibration);
            pan.view.center = CGPointMake(self.controlWidth - countOfCalibration*widthOfCalibration-ineffectiveLength/4, pan.view.center.y);
        }
    }
    /// UI chaging
    if(pan.view == self.leftCursor) {
        [self mainTouchingLeft:pan.view.center];
        _leftValue = round((self.leftCursor.center.x-self.itemRadius)/widthOfCalibration)*self.minimumSize+self.minValue;
    }else{
        [self mainTouchingRight:pan.view.center];
        _rightValue = self.maxValue - round((self.controlWidth-self.rightCursor.center.x-self.itemRadius)/widthOfCalibration)*self.minimumSize;
    }
    [self valueChanging:NO];
    [self cursorOriginChanging:NO];
}

- (void)mainTouchingLeft:(CGPoint)panCenter
{
    if (CGRectGetMaxX(self.leftCursor.frame) > CGRectGetMinX(self.rightCursor.frame)) {
        //重叠
        CGRect frame = self.leftCursor.frame;
        frame.origin.x = CGRectGetMinX(self.rightCursor.frame)-self.itemSize;
        self.leftCursor.frame = frame;
    }else{
        if (panCenter.x < self.itemRadius) {
            //脱离
            CGPoint center = self.leftCursor.center;
            center.x = self.itemRadius;
            self.leftCursor.center = center;
        }
        if (panCenter.x > CGRectGetWidth(self.bounds)-self.itemRadius) {
            CGPoint center = self.leftCursor.center;
            center.x = CGRectGetWidth(self.bounds)-self.itemRadius;
            self.leftCursor.center = center;
        }
    }
    //线
    CGRect frameOfLine = self.leftLine.frame;
    frameOfLine.size.width = self.leftCursor.center.x - self.itemRadius;
    if(self.offsetOfAdjustLineStart){
        frameOfLine.size.width -= self.offsetOfAdjustLineStart;
    }
    if(self.offsetOfAdjustLineEnd){
        frameOfLine.size.width += self.offsetOfAdjustLineEnd;
    }
    self.leftLine.frame = frameOfLine;
}

- (void)mainTouchingRight:(CGPoint)panCenter
{
    if (CGRectGetMinX(self.rightCursor.frame) < CGRectGetMaxX(self.leftCursor.frame)) {
        CGRect frame = self.rightCursor.frame;
        frame.origin.x = CGRectGetMaxX(self.leftCursor.frame);
        self.rightCursor.frame = frame;
    }else{
        if (panCenter.x < self.itemRadius) {
            CGPoint center = self.rightCursor.center;
            center.x = self.itemRadius;
            self.rightCursor.center = center;
        }
        if (panCenter.x > CGRectGetWidth(self.bounds)-self.itemRadius) {
            CGPoint center = self.rightCursor.center;
            center.x = CGRectGetWidth(self.bounds)-self.itemRadius;
            self.rightCursor.center = center;
        }
    }
    CGRect frameOfLine = self.rightLine.frame;
    frameOfLine.size.width = CGRectGetWidth(self.bounds) - self.rightCursor.center.x - self.itemRadius;
    frameOfLine.origin.x = self.rightCursor.center.x;
    if(self.offsetOfAdjustLineEnd){
        frameOfLine.origin.x -= self.offsetOfAdjustLineEnd;
        frameOfLine.size.width += self.offsetOfAdjustLineEnd;
    }
    if(self.offsetOfAdjustLineStart){
        frameOfLine.size.width -= self.offsetOfAdjustLineStart;
    }
    self.rightLine.frame = frameOfLine;
}

/// @param sys -1 non, 0 user, 1 system
- (void)valueChanging:(int)sys
{
    if(sys == -1) return;
    SDRangeSliderValues* values = [SDRangeSliderValues new];
    [values setValue:@(sys) forKey:@"_isSystemMessage"];
    values.thisSlider = self;
    values.left = [NSNumber numberWithDouble:_leftValue];
    values.right = [NSNumber numberWithDouble:_rightValue];
    if(self.blockOfValueDidChanged){
        self.blockOfValueDidChanged(values);
    }
    if([self.delegate respondsToSelector:@selector(rangeSliderValueDidChangedTo:)]){
        [self.delegate rangeSliderValueDidChangedTo:values];
    }
    if(self.signalRangeSliderValueDidChanged) {
        ((void(*)(id,SEL,id))_imp_sendNext)(self.signalRangeSliderValueDidChanged, _sel_sendNext, values);
    }
}

/// @param sys -1 non, 0 user, 1 system
- (void)cursorOriginChanging:(int)sys
{
    if(sys == -1) return;
    CGPoint l = [self convertPoint:_leftCursor.frame.origin toView:_converReferencedView];
    CGPoint r = [self convertPoint:_rightCursor.frame.origin toView:_converReferencedView];
    SDRangeSliderPoints* points = [SDRangeSliderPoints new];
    [points setValue:@(sys) forKey:@"_isSystemMessage"];
    points.thisSlider = self;
    points.leftView = _leftCursor;
    points.rightView = _rightCursor;
    points.left = l;
    points.right = r;
    if(self.blockOfCursorOriginDidChanged && _converReferencedView) {
        self.blockOfCursorOriginDidChanged(points);
    }
    if([self.delegate respondsToSelector:@selector(rangeSliderCursorOriginDidChangedTo:)]){
        [self.delegate rangeSliderCursorOriginDidChangedTo:points];
    }
    if(self.signalRangeSliderCursorOriginDidChanged) {
        ((void(*)(id,SEL,id))_imp_sendNext)(self.signalRangeSliderCursorOriginDidChanged, _sel_sendNext, points);
    }
}
#pragma mark - 用户回调 Custom call back
- (instancetype)eventValueDidChanged:(void (^)(SDRangeSliderValues * _Nonnull))block
{
    _blockOfValueDidChanged = block;
    [self valueChanging:YES];
    return self;
}

- (instancetype)eventCursorOriginDidChanged:(void (^)(SDRangeSliderPoints * _Nonnull))block converToView:(UIView * _Nullable __weak)view
{
    _blockOfCursorOriginDidChanged = [block copy];
    _converReferencedView = view;
    [self cursorOriginChanging:YES];
    return self;
}

#pragma mark - 用户偏好 User preference
- (instancetype)customButtonStyleUsingBlock:(void (^)(SDRangeSliderCursor *, SDRangeSliderCursor *))block
{
    if(block) {
        block(self.leftCursor, self.rightCursor);
    }
    return self;
}

- (SDRangeSlider *(^)(void))usingValueAtFront
{
    _valueMargin = 0;
    return ^id(void){
        return self;
    };
}

- (SDRangeSlider *(^)(void))usingValueUnequal
{
    _valueMargin = 1;
    return ^id(void){
        return self;
    };
}

- (void)setEnabled:(BOOL)enable
{
    if(_enabled == enable) return;
    _enabled = enable;
    [self.backgroundLine setBackgroundColor:enable ? self.highlightLineColor : self.disableHighlightLineColor];
    [self.leftLine setBackgroundColor:enable ? self.lineColor : self.disableLineColor];
    [self.rightLine setBackgroundColor:enable ? self.lineColor : self.disableLineColor];
    [self.rightCursor setEnabled:enable];
    [self.leftCursor setEnabled:enable];
}

#pragma mark 链式编程 Link code
- (SDRangeSlider *(^)(double))usingMinimumSize
{
    return ^id(double val){
        self.minimumSize = val;
        return self;
    };
}

- (SDRangeSlider *(^)(double))usingMinValue
{
    return ^id(double val){
        self.minValue = val;
        return self;
    };
}

- (SDRangeSlider *(^)(double))usingMaxValue
{
    return ^id(double val){
        self.maxValue = val;
        return self;
    };
}

- (SDRangeSlider *(^)(CGFloat))usingLineHeight
{
    return ^id(CGFloat h){
        self.lineHeight = h;
        return self;
    };
}

- (SDRangeSlider *(^)(UIColor*))usingLineColor
{
    return ^id(UIColor* color){
        self.lineColor = color;
        return self;
    };
}

- (SDRangeSlider *(^)(UIColor*))usingHighlightLineColor
{
    return ^id(UIColor* color){
        self.highlightLineColor = color;
        return self;
    };
}

- (SDRangeSlider *(^)(void))usingSystemSliderHeight
{
    return ^id(){
        if(!self.constraints.count) {
            self.itemSize = 30;
        } else {
            for (NSLayoutConstraint * cst in self.constraints) {
                if (cst.firstAttribute == NSLayoutAttributeHeight && cst.firstItem == self){
                    cst.constant = 30;
                    [self setValue:@30 forKey:@"_itemSize"];
                }
            }
        }
        return [self update];
    };
}

- (SDRangeSlider * _Nonnull (^)(BOOL))usingEnable
{
    return ^id(BOOL enable){
        self.enabled = enable;
        return self;
    };
}

#pragma mark - 其他
- (SDRangeSlider*)update
{
    _isNeedUpdate = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    return self;
}
@end
