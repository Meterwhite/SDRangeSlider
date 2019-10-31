//
//  SDRangeSliderPoints.m
//  SDRangeSliderView
//
//  Created by MeterWhite on 2019/10/28.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import "SDRangeSliderPoints.h"

@implementation SDRangeSliderPoints
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isSystemMessage = NO;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f) .. (%f, %f)",_left.x, _left.y, _right.x, _right.y];
}

- (NSString *)debugDescription
{
    return [self description];
}
@end
