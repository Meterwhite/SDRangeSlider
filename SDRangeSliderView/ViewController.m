//
//  ViewController.m
//  SDRangeSliderView
//
//  Created by NOVO on 2018/1/4.
//  Copyright © 2018年 NOVO. All rights reserved.
//

#import "ViewController.h"
#import "SDRangeSliderView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SDRangeSliderView* slider = [[SDRangeSliderView alloc] initWithFrame:CGRectMake(0, 100, 300, 50)];
    
    /*
     *打开每个注释观察变化(Open comment to observe the change)
     */
//    slider.minimumSize = 10;
    
//    slider.offsetOfAdjustLineStart = -12;//look at viewHierarcy
    
//    slider.offsetOfAdjustLineEnd = 15;//look at viewHierarcy
    
//    [slider usingValueAtCenter];//look at viewHierarcy
    
//    [slider customUIUsingBlock:^(UIButton *leftCursor, UIButton *rightCursor) {
//        [leftCursor setImage:nil forState:UIControlStateNormal];
//        leftCursor.backgroundColor = UIColor.redColor;
//        [rightCursor setImage:nil forState:UIControlStateNormal];
//        rightCursor.backgroundColor = UIColor.redColor;
//    }];
    
    [self.view addSubview:slider];
    
    UILabel* info = [[UILabel alloc] initWithFrame:CGRectMake(15, 64, 300, 20)];
    info.text = @"SDRangeSliderView";
    [self.view addSubview:info];
    
    [slider eventValueDidChanged:^(double left, double right) {
        info.text = [NSString stringWithFormat:@"%@~%@",@(left),@(right)];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
