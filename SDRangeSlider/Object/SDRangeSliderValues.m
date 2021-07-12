//
//  SDRangeSliderValues.m
//  SDRangeSliderView
//
//  Created by MeterWhite on 2019/10/28.
//  Copyright © 2019 Meterwhite. All rights reserved.
//

#import "SDRangeSliderValues.h"

@implementation SDRangeSliderValues
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
    return [NSString stringWithFormat:@"%@ .. %@",self.left, self.right];
}

- (NSString *)debugDescription
{
    return [self description];
}

- (NSNumber *)validLength
{
    return  [NSNumber numberWithDouble:_right.doubleValue - _left.doubleValue];
}

- (NSRange)validRange
{
    return NSMakeRange(_left.unsignedIntegerValue, _right.unsignedIntegerValue - _left.unsignedIntegerValue);
}
@end
