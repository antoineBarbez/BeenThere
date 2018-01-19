//
//  VideoSlider.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 26/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "VideoSlider.h"


@interface VideoSlider ()
{
    CMTime assetDuration;
}

@end

@implementation VideoSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *className = NSStringFromClass([self class]);
    UIView *view = [[bundle loadNibNamed:className owner:self options:nil] firstObject];
    view.frame = self.bounds;
    
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
    
    [self setupLabel];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = false;
    self.scrollView.delegate = self;
    
    self.scrollView.showsVerticalScrollIndicator = false;
    self.scrollView.showsHorizontalScrollIndicator = false;
    
    self.userIsDragging = NO;
}

-(void) setupLabel {
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 60, 18)];
    self.label.contentMode = UIViewContentModeCenter;
    self.label.backgroundColor = [UIColor lightGrayColor];
    self.label.alpha = 0.8;
    [self.label setFont:[UIFont fontWithName:@"MuseoSans-500" size:14]];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.label setTextColor:[UIColor blackColor]];
    self.label.layer.cornerRadius = self.label.frame.size.height/2;
    self.label.layer.masksToBounds = YES;
    self.label.hidden = YES;
    self.label.center = self.backgroundView.center;
    
    [self insertSubview:self.label atIndex:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.contentSize = self.contentView.frame.size;
    
    //Recenter the label
    CGRect labelFrame = self.label.frame;
    labelFrame.origin.x = self.backgroundView.center.x - labelFrame.size.width/2;
    [self.label setFrame:labelFrame];
}

-(void)hideLabel {
    [UIView animateWithDuration:0.17
                     animations:^{
                         self.label.center = self.backgroundView.center;
                     }
                     completion:^(BOOL finished) {
                         self.label.hidden = YES;
                     }
     ];
}

-(void)showLabel {
    self.label.hidden = NO;
    
    CGRect finalFrame = self.label.frame;
    finalFrame.origin.y = 0;
    [UIView animateWithDuration:0.17
                     animations:^{
                         self.label.frame = finalFrame;
                     }
     ];
    
}


-(void) setUrl:(NSURL *)url {
    if (![_url isEqual:url]) {
        _url = url;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL: url options:nil];
    assetDuration = asset.duration;
    
    [self.contentView regenerateThumbnailsForAsset:asset];
}

-(void) seekToTime:(CMTime)time {
    CGFloat value = [self valueForTime:time];
    
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = value*self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:offset];
}

-(void) setValue:(float)value {
    if (_value != value && value >= 0.0 && value <= 1.0) {
        _value = value;
        
        CGPoint offset = self.scrollView.contentOffset;
        offset.x = value*self.scrollView.frame.size.width;
        [self.scrollView setContentOffset:offset];
    }
}

-(CMTime)timeForValue:(CGFloat)value {
    CGFloat positionTimeValue = value * (CGFloat)assetDuration.value;
    
    return CMTimeMake((int64_t)positionTimeValue, assetDuration.timescale);
}

-(CGFloat)valueForTime:(CMTime)time {
    CGFloat timeRatio = (CGFloat)time.value*(CGFloat)assetDuration.timescale/((CGFloat)time.timescale*(CGFloat)assetDuration.value);
    
    return timeRatio;
}

-(NSString *)stringForTime:(CMTime)time {
    NSString *timeString;
    int secondsValue = ceil(time.value/time.timescale);
    int sec = secondsValue % 60;
    int minValue = (int)((secondsValue - sec)/60);
    int min;
    if (secondsValue >=3600) {
        min = minValue % 60;
        int hr = (int)((minValue - min)/60);
        
        timeString = [NSString stringWithFormat:@"%i:%i:%i",hr, min, sec];
        return timeString;
    }
    
    min = minValue;
    timeString = [NSString stringWithFormat:@"%i:%i",min,sec];
    
    return timeString;
}


#pragma mark - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float normalizedValue = scrollView.contentOffset.x/scrollView.frame.size.width;
    float newValue = MAX(0.0, MIN(1.0, normalizedValue));
    
    if (_value != newValue) {
        _value = newValue;
    }
    
    CMTime time = [self timeForValue:self.value];
    NSString *timeString = [self stringForTime:time];
    
    
    if (![self.label.text isEqualToString:timeString]) {
        self.label.text = timeString;
    }
    
    
    switch (scrollView.panGestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            
            // User began dragging
            self.userIsDragging = YES;
            [self showLabel];
            break;
            
        case UIGestureRecognizerStateChanged:
            
            // User is currently dragging the scroll view
            if (!self.userIsDragging) {
                self.userIsDragging = YES;
                [self showLabel];
            }
            if (self.label.hidden) {
                self.label.hidden = NO;
            }
            [self.delegate didChangePositionBar:[self timeForValue:self.value] forValue:self.value];
            break;
            
        case UIGestureRecognizerStatePossible:
            
            // The scroll view scrolling but the user is no longer touching the scrollview (table is decelerating)
            if (self.userIsDragging) {
                if (self.label.hidden) {
                    self.label.hidden = NO;
                }
                [self.delegate didChangePositionBar:[self timeForValue:self.value] forValue:self.value];
            }
            break;
            
        default:
            break;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.userIsDragging = NO;
    [self.delegate stoppedChangingPositionBar:[self timeForValue:self.value]];
    [self hideLabel];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.userIsDragging = NO;
        [self.delegate stoppedChangingPositionBar:[self timeForValue:self.value]];
        [self hideLabel];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
