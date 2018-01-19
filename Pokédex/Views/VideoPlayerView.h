//
//  VideoPlayerView.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 02/08/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayerView : UIView
{
    AVPlayerLayer *playerLayer;
    BOOL isSeekInProgress;
    CMTime chaseTime;
}

@property (retain, nonatomic) AVPlayer *moviePlayer;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL finishPlaying;
@property (assign, nonatomic) BOOL videoHasBegin;


-(id)initWithFrame:(CGRect)frame contentURL:(NSURL*)contentURL;
-(void)reset;
-(void)play;
-(void)pause;
- (void)seekSmoothlyToTime:(CMTime)newChaseTime;
@end
