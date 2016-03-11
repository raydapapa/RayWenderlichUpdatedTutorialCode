//
//  CERangeSlider.m
//  CERangeSlider
//
//  Created by yww on 3/8/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "CERangeSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "CERangeSliderKnobLayer.h"
#import "CERangeSliderTrackLayer.h"

@interface CERangeSlider ()
{
//    CALayer *_trackLayer;
//    CALayer *_upperKnobLayer;
//    CALayer *_lowerKnobLayer;
    CERangeSliderTrackLayer *_trackLayer;
    CERangeSliderKnobLayer *_upperKnobLayer;
    CERangeSliderKnobLayer *_lowerKnobLayer;
    
    float _knobWidth;
    float _useableTrackLength;
    CGPoint _previousTouchPoint;
}
@end


@implementation CERangeSlider

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER: (TYPE)PROPERTY { \
    if (_##PROPERTY != PROPERTY) { \
        _##PROPERTY = PROPERTY; \
        [self UPDATER]; \
    } \
}

GENERATE_SETTER(trackHighlightColor, UIColor *, setTrackHighlightColor, redrawLayers)
GENERATE_SETTER(trackColor, UIColor *, setTrackColor, redrawLayers)
GENERATE_SETTER(knobColor, UIColor *, setKnobColor, redrawLayers)
GENERATE_SETTER(curvaceousness, float, setCurvaceousness, redrawLayers)
GENERATE_SETTER(maximumValue, float, setMaximumValue, setLayerFrames)
GENERATE_SETTER(minimumValue, float, setMinimumValue, setLayerFrames)
GENERATE_SETTER(lowerValue, float, setLowerValue, setLayerFrames)
GENERATE_SETTER(upperValue, float, setUpperValue, setLayerFrames)

- (void)redrawLayers {
    [_upperKnobLayer setNeedsDisplay];
    [_lowerKnobLayer setNeedsDisplay];
    [_trackLayer setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _trackHighlightColor = [UIColor colorWithRed:0 green:0.45    blue:0.94 alpha:1.0];
        _trackColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _knobColor = [UIColor whiteColor];
        _curvaceousness = 1.0;
        
        _maximumValue = 10.0;
        _minimumValue = 0.0;
        _upperValue = 8.0;
        _lowerValue = 2.0;
        
//        _trackLayer = [CALayer layer];
        _trackLayer = [CERangeSliderTrackLayer layer];
        _trackLayer.slider = self;
//        _trackLayer.backgroundColor = [UIColor blueColor].CGColor;
        [self.layer addSublayer:_trackLayer];
        
//        _upperKnobLayer = [CALayer layer];
        _upperKnobLayer = [CERangeSliderKnobLayer layer];
        _upperKnobLayer.slider = self;
//        _upperKnobLayer.backgroundColor = [UIColor greenColor].CGColor;
        [self.layer addSublayer:_upperKnobLayer];
        
//        _lowerKnobLayer = [CALayer layer];
        _lowerKnobLayer = [CERangeSliderKnobLayer layer];
        _lowerKnobLayer.slider = self;
//        _lowerKnobLayer.backgroundColor = [UIColor grayColor].CGColor;
        [self.layer addSublayer:_lowerKnobLayer];
    
        [self setLayerFrames];
    }
    
    return self;
}


#pragma mark - Private Methods
- (void)setLayerFrames {
    _trackLayer.frame = CGRectInset(self.bounds, 0, self.bounds.size.height / 3.5);
    [_trackLayer setNeedsDisplay];
    
    _knobWidth = self.bounds.size.height;
    // the actual length is self.width - knobWidth, 防止滑块在两端画出slider区域
    _useableTrackLength = self.bounds.size.width - _knobWidth;
    
    float upperKnobCentre = [self positionForValue:_upperValue];
    _upperKnobLayer.frame = CGRectMake(upperKnobCentre - _knobWidth / 2, 0, _knobWidth, _knobWidth);
    
    float lowerKnobCentre = [self positionForValue:_lowerValue];
    _lowerKnobLayer.frame = CGRectMake(lowerKnobCentre - _knobWidth / 2, 0, _knobWidth, _knobWidth);
    
    [_upperKnobLayer setNeedsDisplay];
    [_lowerKnobLayer setNeedsDisplay];
}

- (float)positionForValue:(float)value {
    return _useableTrackLength * (value - _minimumValue) /
    (_maximumValue - _minimumValue) + (_knobWidth / 2);
}

#pragma mark - Override UIControl methods
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    _previousTouchPoint = [touch locationInView:self];
    
    // hit test the knob layers
    if (CGRectContainsPoint(_lowerKnobLayer.frame, _previousTouchPoint)) {
        _lowerKnobLayer.highlighted = YES;
        [_lowerKnobLayer setNeedsDisplay];
    }
    else if(CGRectContainsPoint(_upperKnobLayer.frame, _previousTouchPoint)) {
        _upperKnobLayer.highlighted = YES;
        [_upperKnobLayer setNeedsDisplay];
    }
    
    return _upperKnobLayer.highlighted || _lowerKnobLayer.highlighted;
}

#define BOUND(VALUE, UPPER, LOWER) MIN(MAX(VALUE, LOWER), UPPER)
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    
    // 1. determine by how much the user has dragged
    float delta = touchPoint.x - _previousTouchPoint.x;
    float valueDelta = (_maximumValue - _minimumValue) * delta / _useableTrackLength;
    
    _previousTouchPoint = touchPoint;
    
    // 2. update the values
    if (_lowerKnobLayer.highlighted) {
        _lowerValue += valueDelta;
        _lowerValue = BOUND(_lowerValue, _upperValue, _minimumValue);
    }
    if (_upperKnobLayer.highlighted) {
        _upperValue += valueDelta;
        _upperValue = BOUND(_upperValue, _maximumValue, _lowerValue);
    }
    
    // 3. update the UI state
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self setLayerFrames];
    
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    _lowerKnobLayer.highlighted = _upperKnobLayer.highlighted = NO;
    [_lowerKnobLayer setNeedsDisplay];
    [_upperKnobLayer setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end