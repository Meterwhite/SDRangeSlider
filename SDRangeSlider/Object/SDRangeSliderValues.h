//
//  SDRangeSliderValues.h
//  SDRangeSliderView
//
//  Created by MeterWhite on 2019/10/28.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDRangeSliderResponder.h"

@class SDRangeSlider;
@interface SDRangeSliderValues : NSObject<SDRangeSliderResponder>
#pragma mark - Main
/// Instead of weak slider
@property (nullable,nonatomic,weak) SDRangeSlider *thisSlider;
@property (nonnull,nonatomic,strong) NSNumber *left;
@property (nonnull,nonatomic,strong) NSNumber *right;
#pragma mark - More
@property (nonatomic,readonly) BOOL isSystemMessage;
/// '3 ~ 5'' -> '3'
@property (nonnull,nonatomic,strong,readonly) NSNumber* validLength;
/// '3 ~ 5' -> 'NSRange(3, 3)'
@property (nonatomic,readonly) NSRange validRange;
- (nonnull NSString *)description;
@end

