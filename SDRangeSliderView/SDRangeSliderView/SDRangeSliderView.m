//
//  SDRangeSliderView.m
//  SDRangeSliderView
//
//  Created by NOVO on 2018/1/3.
//  Copyright © 2018年 NOVO. All rights reserved.
//

#import "SDRangeSliderView.h"

@interface SDRangeSliderView()

@property (nonatomic,assign) double leftValue;
@property (nonatomic,assign) double rightValue;


/**
 游标按钮(Button of cursor)
 */
@property (nonatomic,strong) UIButton* leftCursorButton;
@property (nonatomic,strong) UIButton* rightCursorButton;
@property (nonatomic,strong) UIView* backgroundLine;
@property (nonatomic,strong) UIView* leftLine;
@property (nonatomic,strong) UIView* rightLine;

@property (nonatomic,assign,readonly) CGFloat itemRadius;

@property (nonatomic,copy) void(^blockOfValueDidChanged)(double left, double right);

/**
 开始取值的偏移量
 */
@property (nonatomic,assign) BOOL valueCanEqual;


@property (nonatomic,strong) UIImage* imageOfNormalButtonLeft;
@property (nonatomic,strong) UIImage* imageOfNormalButtonRight;
@end

@implementation SDRangeSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemSize = 30;
        self.lineHeight = 2;
        self.minimumSize = 1;
        //底部线条
        CGFloat lineY = self.itemRadius-self.lineHeight/2;
        self.backgroundLine = [[UIView alloc] initWithFrame:CGRectMake(self.itemRadius, lineY , CGRectGetWidth(self.bounds)-self.itemSize , self.lineHeight)];
        [self addSubview:self.backgroundLine];
        //左线
        self.leftLine = [[UIView alloc] initWithFrame:CGRectMake(self.itemRadius, lineY, 0, self.lineHeight)];
        [self addSubview:self.leftLine];
        //右线
        self.rightLine = [[UIView alloc] initWithFrame:CGRectMake(self.controlWidth - self.itemRadius, lineY, 0, self.lineHeight)];
        [self addSubview:self.rightLine];
        //左游标按钮
        self.leftCursorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.leftCursorButton];
        self.leftCursorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.leftCursorButton.frame = CGRectMake(0, 0, self.itemSize, self.itemSize);
        UIPanGestureRecognizer* padLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(eventPan:)];
        [self.leftCursorButton addGestureRecognizer:padLeft];
        //右游标按钮
        self.rightCursorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.rightCursorButton];
        self.rightCursorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.rightCursorButton.frame = CGRectMake(CGRectGetWidth(self.bounds)-self.itemRadius, 0, self.itemSize, self.itemSize);
        UIPanGestureRecognizer* padRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(eventPan:)];
        [self.rightCursorButton addGestureRecognizer:padRight];
        
        self.lineColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f] ;
        self.highlightLineColor = [UIColor colorWithRed:22.0f/255.0f green:165.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
        
        {
            [self.rightCursorButton setImage:self.imageOfNormalButtonRight forState:UIControlStateNormal];
            [self.leftCursorButton setImage:self.imageOfNormalButtonLeft forState:UIControlStateNormal];
        }
        self.maxValue = 100.0;
        self.minValue = 0.0;
        self.offsetOfAdjustLineEnd = 0.0;
        self.offsetOfAdjustLineStart = 0.0;
        self.leftDefaultValue = self.minValue;
        self.rightDefaultValue = self.maxValue;
        self.frame = frame;
        self.leftValue = self.leftDefaultValue;
        self.rightValue = self.rightDefaultValue;
        [self usingValueAtFront];
    }
    return self;
}

#pragma mark override UIView
- (void)setFrame:(CGRect)frame
{
    frame.size = CGSizeMake(frame.size.width , self.itemSize);
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    bounds.size = CGSizeMake(bounds.size.width , self.itemSize);
    [super setBounds:bounds];
}


#pragma mark 触摸事件
- (void)eventPan:(UIPanGestureRecognizer*)pan
{
    CGPoint point = [pan translationInView:self];
    static CGPoint center;
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        center = pan.view.center;
    }
    
    pan.view.center = CGPointMake(center.x + point.x, self.itemRadius);
    
    NSInteger totalOfCalibration = (self.maxValue - self.minValue)/self.minimumSize;//刻度总份数
    CGFloat ineffectiveLength = self.itemSize*(self.valueCanEqual?2:1);//无效的坐标系长度
    CGFloat widthOfCalibration = (self.controlWidth-ineffectiveLength)/totalOfCalibration;//一个刻度的宽
    if (pan.state == UIGestureRecognizerStateEnded) {
        /*
         有效长度的坐标首先偏移，找整数刻度值；之后将这个整数刻度值和之前的偏移还原回坐标系统
         */
        if(pan.view == self.leftCursorButton){

            CGFloat countOfCalibration = round((pan.view.center.x-self.itemRadius)/widthOfCalibration);
            pan.view.center = CGPointMake(countOfCalibration*widthOfCalibration+ineffectiveLength/4, pan.view.center.y);
        }else{
            
            CGFloat countOfCalibration = round((self.controlWidth - pan.view.center.x-self.itemRadius)/widthOfCalibration);
            pan.view.center = CGPointMake(self.controlWidth - countOfCalibration*widthOfCalibration-ineffectiveLength/4, pan.view.center.y);
        }
    }
    
    
    if(pan.view == self.leftCursorButton){
        
        if (CGRectGetMaxX(self.leftCursorButton.frame) > CGRectGetMinX(self.rightCursorButton.frame)) {
            
            CGRect frame = self.leftCursorButton.frame;
            frame.origin.x = CGRectGetMinX(self.rightCursorButton.frame)-self.itemSize;
            self.leftCursorButton.frame = frame;
        }else{
            if (pan.view.center.x < self.itemRadius) {
                CGPoint center = self.leftCursorButton.center;
                center.x = self.itemRadius;
                self.leftCursorButton.center = center;
            }
            if (pan.view.center.x > CGRectGetWidth(self.bounds)-self.itemRadius) {
                CGPoint center = self.leftCursorButton.center;
                center.x = CGRectGetWidth(self.bounds)-self.itemRadius;
                self.leftCursorButton.center = center;
            }
        }
        
        CGRect frame = self.leftLine.frame;
        frame.size.width = self.leftCursorButton.center.x - self.itemRadius;
        if(self.offsetOfAdjustLineStart){
            frame.size.width -= self.offsetOfAdjustLineStart;
        }
        if(self.offsetOfAdjustLineEnd){
            frame.size.width += self.offsetOfAdjustLineEnd;
        }
        self.leftLine.frame = frame;
        
        if(!self.valueCanEqual){
            _leftValue = round((self.leftCursorButton.center.x-self.itemRadius)/widthOfCalibration)*self.minimumSize;
        }else{
            _leftValue = round((CGRectGetMaxX(self.leftCursorButton.frame)-self.itemSize)/widthOfCalibration)*self.minimumSize;
        }
        if(self.blockOfValueDidChanged){
            self.blockOfValueDidChanged(_leftValue , _rightValue);
        }
    }else{
        
        if (CGRectGetMinX(self.rightCursorButton.frame) < CGRectGetMaxX(self.leftCursorButton.frame)) {
            
            CGRect frame = self.rightCursorButton.frame;
            frame.origin.x = CGRectGetMaxX(self.leftCursorButton.frame);
            self.rightCursorButton.frame = frame;
        }else{
            if (pan.view.center.x < self.itemRadius) {
                CGPoint center = self.rightCursorButton.center;
                center.x = self.itemRadius;
                self.rightCursorButton.center = center;
            }
            if (pan.view.center.x > CGRectGetWidth(self.bounds)-self.itemRadius) {
                CGPoint center = self.rightCursorButton.center;
                center.x = CGRectGetWidth(self.bounds)-self.itemRadius;
                self.rightCursorButton.center = center;
            }
        }
        
        CGRect frame = self.rightLine.frame;
        frame.size.width = CGRectGetWidth(self.bounds) - self.rightCursorButton.center.x - self.itemRadius;
        frame.origin.x = self.rightCursorButton.center.x;
        if(self.offsetOfAdjustLineEnd){
            frame.origin.x -= self.offsetOfAdjustLineEnd;
            frame.size.width += self.offsetOfAdjustLineEnd;
        }
        if(self.offsetOfAdjustLineStart){
            frame.size.width -= self.offsetOfAdjustLineStart;
        }
        self.rightLine.frame = frame;
        
        if(!self.valueCanEqual){
            _rightValue = self.maxValue - round((self.controlWidth-self.rightCursorButton.center.x-self.itemRadius)/widthOfCalibration)*self.minimumSize;
        }else{
            _rightValue = self.maxValue - round((self.controlWidth-CGRectGetMinX(self.rightCursorButton.frame)-self.itemSize)/widthOfCalibration)*self.minimumSize;
        }
        if(self.blockOfValueDidChanged){
            self.blockOfValueDidChanged(_leftValue , _rightValue);
        }
    }
}
#pragma mark 设置左游标值
- (void)setLeftValue:(double)leftValue
{
    _leftValue = leftValue;
    
    NSInteger totalOfCalibration = (self.maxValue - self.minValue)/self.minimumSize;
    CGFloat widthOfCalibration = (self.controlWidth-self.itemSize*(self.valueCanEqual?2:1))/totalOfCalibration;
    
    //按钮
    CGRect framOfButton= self.leftCursorButton.frame;
    framOfButton.origin.x = widthOfCalibration*leftValue;
    self.leftCursorButton.frame = framOfButton;
    //线
    CGRect framOfLine = self.leftLine.frame;
    framOfLine.size.width = widthOfCalibration*leftValue + self.offsetOfAdjustLineEnd;
    if(self.offsetOfAdjustLineStart){
        framOfLine.origin.x += self.offsetOfAdjustLineStart;
        framOfLine.size.width -= self.offsetOfAdjustLineStart;
    }
    self.leftLine.frame = framOfLine;
}
#pragma mark 设置右游标值
- (void)setRightValue:(double)rightValue
{
    
    _rightValue = rightValue;
    
    NSInteger totalOfCalibration = (self.maxValue - self.minValue)/self.minimumSize;//总份
    CGFloat widthOfCalibration = (self.controlWidth-self.itemSize*(self.valueCanEqual?2:1))/totalOfCalibration;//份长
    
    //按钮
    CGRect framOfButton= self.rightCursorButton.frame;
    framOfButton.origin.x = widthOfCalibration*rightValue;
    self.rightCursorButton.frame = framOfButton;
    //线
    CGRect framOfLine = self.rightLine.frame;
    framOfLine.size.width = self.controlWidth - widthOfCalibration*rightValue - self.itemSize + self.offsetOfAdjustLineStart;
    if(self.offsetOfAdjustLineEnd){
        
        framOfLine.origin.x -= self.offsetOfAdjustLineEnd;
        framOfLine.size.width += self.offsetOfAdjustLineEnd;
    }
    self.rightLine.frame = framOfLine;
}

- (void)eventValueDidChanged:(void (^)(double, double))block
{
    self.blockOfValueDidChanged = block;
}

- (void)customUIUsingBlock:(void (^)(UIButton *, UIButton *))block
{
    if(block) block(self.leftCursorButton, self.rightCursorButton);
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
    self.leftLine.backgroundColor = lineColor;
    self.rightLine.backgroundColor = lineColor;
}

- (void)setHighlightLineColor:(UIColor *)highlightLineColor
{
    self.backgroundLine.backgroundColor = highlightLineColor;
}


- (CGFloat)itemRadius
{
    return self.itemSize/2;
}

- (void)usingValueAtFront
{
    self.valueCanEqual = YES;
}

- (void)usingValueAtCenter
{
    self.valueCanEqual = NO;
}

- (CGFloat)controlWidth
{
    return self.frame.size.width;
}

- (UIImage *)imageOfNormalButtonLeft
{
    if(!_imageOfNormalButtonLeft){
        UIView* view = [UIView new];
        CGFloat scale = [UIScreen mainScreen].scale;
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, 0, self.itemSize*scale, self.itemSize*scale);
        
        CALayer* layerShadow = [CALayer layer];
        CGFloat margin = 2;
        layerShadow.frame = CGRectMake( 2*margin*scale, margin*scale, (self.itemSize-margin*2)*scale, (self.itemSize-margin*2)*scale);
        layerShadow.backgroundColor = [UIColor clearColor].CGColor;
        layerShadow.cornerRadius = layerShadow.bounds.size.width/2;
        layerShadow.shadowRadius = 1;
        layerShadow.shadowColor = [UIColor blackColor].CGColor;
        layerShadow.shadowOffset = CGSizeMake(0, 0.5);
        layerShadow.shadowOpacity=0.4;
        
        CALayer* layerBtn = [CALayer layer];
        layerBtn.backgroundColor = [UIColor whiteColor].CGColor;
        layerBtn.frame = layerShadow.bounds;
        layerBtn.masksToBounds = YES;
        layerBtn.cornerRadius = layerBtn.bounds.size.width/2;
        
        [layerShadow addSublayer:layerBtn];
        [view.layer addSublayer:layerShadow];
        
        //截图(screenshots)
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, YES);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *re = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _imageOfNormalButtonLeft = re;
    }
    return _imageOfNormalButtonLeft;
}

- (UIImage *)imageOfNormalButtonRight
{
    if(!_imageOfNormalButtonRight){
        UIView* view = [UIView new];
        CGFloat scale = [UIScreen mainScreen].scale;
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, 0, self.itemSize*scale, self.itemSize*scale);
        
        CALayer* layerShadow = [CALayer layer];
        CGFloat margin = 2;
        layerShadow.frame = CGRectMake(0 , margin*scale, (self.itemSize-margin*2)*scale, (self.itemSize-margin*2)*scale);
        layerShadow.backgroundColor = [UIColor clearColor].CGColor;
        layerShadow.cornerRadius = layerShadow.bounds.size.width/2;
        layerShadow.shadowRadius = 1;
        layerShadow.shadowColor = [UIColor blackColor].CGColor;
        layerShadow.shadowOffset = CGSizeMake(0, 0.5);
        layerShadow.shadowOpacity=0.4;
        
        CALayer* layerBtn = [CALayer layer];
        layerBtn.backgroundColor = [UIColor whiteColor].CGColor;
        layerBtn.frame = layerShadow.bounds;
        layerBtn.masksToBounds = YES;
        layerBtn.cornerRadius = layerBtn.bounds.size.width/2;
        layerBtn.borderColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
        layerBtn.borderWidth = 0.5;
        
        [layerShadow addSublayer:layerBtn];
        
        [view.layer addSublayer:layerShadow];
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, YES);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *re = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _imageOfNormalButtonRight = re;
    }
    return _imageOfNormalButtonRight;
}
@end
