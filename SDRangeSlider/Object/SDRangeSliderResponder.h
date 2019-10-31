//
//  SDRangeSliderResponder.h
//  SDRangeSliderDemo
//
//  Created by MeterWhite on 2019/10/30.
//  Copyright © 2019 Meterwhite. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SDRangeSlider;
@protocol SDRangeSliderResponder <NSObject>
@required
@property (nullable,nonatomic,weak) SDRangeSlider *thisSlider;
@property (nonatomic,readonly) BOOL isSystemMessage;
@end
