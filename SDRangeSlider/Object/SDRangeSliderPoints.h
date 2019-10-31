//
//  SDRangeSliderPoints.h
//  SDRangeSliderView
//
//  Created by MeterWhite on 2019/10/28.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDRangeSliderResponder.h"
#import <UIKit/UIKit.h>

@class SDRangeSlider;
@interface SDRangeSliderPoints : NSObject<SDRangeSliderResponder>
/// Instead of weak slider
@property (nullable,nonatomic,weak) SDRangeSlider *thisSlider;
@property (nullable,nonatomic,weak) UIButton *rightView;
@property (nullable,nonatomic,weak) UIButton *leftView;
@property (nonatomic) CGPoint left;
@property (nonatomic) CGPoint right;
#pragma mark - More
@property (nonatomic,readonly) BOOL isSystemMessage;
- (nonnull NSString *)description;
@end

