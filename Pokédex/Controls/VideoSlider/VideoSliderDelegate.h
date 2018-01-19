//
//  VideoSliderDelegate.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 03/10/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol VideoSliderDelegate <NSObject>

-(void)didChangePositionBar:(CMTime)newTime forValue:(CGFloat)value;
-(void)stoppedChangingPositionBar:(CMTime)finalTime;

@end
