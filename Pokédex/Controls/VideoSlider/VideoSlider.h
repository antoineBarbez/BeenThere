//
//  VideoSlider.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 26/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "VideoSliderContentView.h"
#import "VideoSliderDelegate.h"


@interface VideoSlider : UIControl <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <VideoSliderDelegate> delegate;

@property (nonatomic) float value;
@property (assign, nonatomic) BOOL userIsDragging;
@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) IBOutlet VideoSliderContentView *contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

-(void) seekToTime:(CMTime)time;


@end
