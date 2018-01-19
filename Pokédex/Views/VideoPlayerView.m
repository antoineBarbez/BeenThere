//
//  VideoPlayerView.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 02/08/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "VideoPlayerView.h"

@implementation VideoPlayerView


- (id)initWithFrame:(CGRect)frame contentURL:(NSURL*)contentURL
{
    self = [super initWithFrame:frame];
    if (self) {
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:contentURL];
        self.moviePlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
        [playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.moviePlayer seekToTime:kCMTimeZero];
        [self.layer addSublayer:playerLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        self.finishPlaying = NO;
        self.videoHasBegin = NO;
        
        isSeekInProgress = NO;
        chaseTime = kCMTimeZero;
    }
    return self;
}


-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)playerFinishedPlaying
{
    [self.moviePlayer pause];
    self.finishPlaying = YES;
}

-(void)reset
{
    [self pause];
    [self.moviePlayer seekToTime:kCMTimeZero];
    self.finishPlaying = NO;
    self.videoHasBegin = NO;
}

-(void)play
{
    [self.moviePlayer play];
    self.isPlaying = YES;
    self.videoHasBegin = YES;
}

-(void)pause
{
    [self.moviePlayer pause];
    self.isPlaying = NO;
}


// Smooth seeking
- (void)seekSmoothlyToTime:(CMTime)newChaseTime
{
    if (CMTIME_COMPARE_INLINE(newChaseTime, !=, chaseTime))
    {
        chaseTime = newChaseTime;
        
        if (!isSeekInProgress)
            [self trySeekToChaseTime];
    }
}

- (void)trySeekToChaseTime
{
    if (self.moviePlayer.currentItem.status == AVPlayerItemStatusUnknown)
    {
        // wait until item becomes ready
    }
    else if (self.moviePlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        [self actuallySeekToTime];
    }
}

- (void)actuallySeekToTime
{
    isSeekInProgress = YES;
    CMTime seekTimeInProgress = chaseTime;
    [self.moviePlayer seekToTime:seekTimeInProgress toleranceBefore:kCMTimeZero
              toleranceAfter:kCMTimeZero completionHandler:
     ^(BOOL isFinished)
     {
         if (CMTIME_COMPARE_INLINE(seekTimeInProgress, ==, chaseTime))
             isSeekInProgress = NO;
         else
             [self trySeekToChaseTime];
     }];
}
@end
