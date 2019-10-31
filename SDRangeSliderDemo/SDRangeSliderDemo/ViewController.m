//
//  ViewController.m
//  SDRangeSlider
//
//  Created by Meterwhite on 2018/1/4.
//  Copyright © 2018年 Meterwhite. All rights reserved.
//

#import "ViewController.h"
#import "SDRangeSlider.h"
#import "ReactiveObjc.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet SDRangeSlider *sliderAut;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightX;
@property (weak, nonatomic) IBOutlet UILabel *leftLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfH;

@property (weak, nonatomic) IBOutlet SDRangeSlider *customStyleSlider;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    #pragma mark - Frame layout
    SDRangeSlider* slider = [[SDRangeSlider alloc] initWithFrame:CGRectMake(0, 100, 300, 50)].usingSystemSliderHeight().usingMinimumSize(1).usingMinValue(18).usingMaxValue(99);
    [self.view addSubview:slider];
    UILabel* info = [[UILabel alloc] initWithFrame:CGRectMake(15, 64, 300, 20)];
    info.text = @"SDRangeSlider";
    [self.view addSubview:info];
    [slider eventValueDidChanged:^(SDRangeSliderValues* values) {
        if(values.isSystemMessage) {
            return;
        }
        NSLog(@"User drag info: %@",values.description);
        info.text = [NSString stringWithFormat:@"Frame layout : %@",values.description];
    }];
    
    
    #pragma mark - Autolayout
    __weak ViewController* weak_self = self;
    [self.sliderAut eventCursorOriginDidChanged:^(SDRangeSliderPoints* points) {
        CGFloat h = points.thisSlider.bounds.size.height;
        weak_self.leftX.constant = points.left.x + h*0.5;
        weak_self.rightX.constant = points.right.x + h*0.5 - 10;
        weak_self.leftLab.text = [NSString stringWithFormat:@"%lu", (NSInteger)points.thisSlider.leftValue];
        weak_self.rightLab.text = [NSString stringWithFormat:@"%lu", (NSInteger)points.thisSlider.rightValue];
    } converToView:self.view];
    
    [self.sliderAut.signalRangeSliderValueDidChanged subscribeNext:^(SDRangeSliderValues *values) {
        weak_self.selfH.constant = 28 + values.validLength.intValue;
        [values.thisSlider update];
    }];
    /**
     使用RAC过滤出用户交互产生的信息
     [[self.sliderAut.signalRangeSliderValueDidChanged filter:^BOOL(SDRangeSliderValues* values) {
        return values.isSystemMessage == NO;
     }] subscribeNext:^(SDRangeSliderValues* values) {
        NSLog(@"User message from UI: %@",values);
     }];
     */
    
    #pragma mark - Custom style
    self.customStyleSlider.usingHighlightLineColor(UIColor.systemPinkColor);
    [self.customStyleSlider customButtonStyleUsingBlock:^(SDRangeSliderCursor *left, SDRangeSliderCursor *right) {
       
       /// As a view
        left.usingCustomStyle().usingRoundStyle().usingBackgroundColor(UIColor.lightGrayColor).usingBorderColor(UIColor.systemPinkColor).usingBorderWidth(0.5);
        right.usingCustomStyle().usingRoundStyle().usingBackgroundColor(UIColor.lightGrayColor).usingBorderColor(UIColor.systemPinkColor).usingBorderWidth(0.5);
        /// As a button
        /**
         [left.usingImageRight() setImage:[UIImage imageNamed:@"?"] forState:UIControlStateNormal];
         [right.usingImageLeft() setImage:[UIImage imageNamed:@"?"] forState:UIControlStateNormal];
         */
    }];
}
@end
