//
//  GalleryCollectionViewCell.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 29/06/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "GalleryCollectionViewCell.h"

@interface GalleryCollectionViewCell()
{
    CGSize mediaSize;
}
@end

@implementation GalleryCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"GalleryCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        self.scrollView.delegate = self;
    }
    
    return self;
}



-(void) resetForSize:(CGSize) size {
    [self updateMinMaxZoomScaleForSize:size];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    [self updateMediaViewOrigineForSize:size];
}


-(void)updateCell {
    if (self.media != nil) {
        mediaSize = CGSizeMake(((UIImage*)[self.media objectForKey:@"image"]).size.width, ((UIImage*)[self.media objectForKey:@"image"]).size.height);
        
        if ([[self.media objectForKey:@"mediaType"] isEqualToString:@"image"]) {
            UIImage *image = [self.media objectForKey:@"image"];
            [self updateCellWithImage:image];
        }else {
            NSURL * videoURL = [NSURL fileURLWithPath:[self.media objectForKey:@"videoPath"]];
            [self updateCellWithVideoURL:videoURL];
        }
        
        for (UIView *subview in self.scrollView.subviews) {
            [subview removeFromSuperview];
        }
        [self.scrollView addSubview:self.mediaView];
    }
}

-(void)updateCellWithImage:(UIImage *) image {
    self.mediaIsAnImage = YES;
    
    self.mediaView = [[UIImageView alloc] initWithImage:image];
    [self.mediaView setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
}

-(void)updateCellWithVideoURL:(NSURL *) url {
    self.mediaIsAnImage = NO;
    
    CGRect frame = CGRectMake(0.0, 0.0, mediaSize.width, mediaSize.height);
    self.mediaView = [[VideoPlayerView alloc] initWithFrame:frame contentURL:url];
}

-(void) updateMinMaxZoomScaleForSize:(CGSize) size {
    CGFloat widthScale = size.width/mediaSize.width;
    CGFloat heightScale = size.height/mediaSize.height;
    
    CGFloat minScale = MIN(widthScale, heightScale);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = minScale*3;
}

-(void) updateMediaViewOrigineForSize:(CGSize) size {
    
    CGFloat x = MAX(0, (size.width - self.mediaView.frame.size.width)/2);
    CGFloat y = MAX(0, (size.height - self.mediaView.frame.size.height)/2);
    self.mediaView.frame = CGRectMake(x, y, self.mediaView.frame.size.width, self.mediaView.frame.size.height);
}


-(void) doubleTapAtPoint:(CGPoint)point {
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
                             self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
                         }else{
                             [self zoomForScale:self.scrollView.maximumZoomScale
                                        AtPoint:point];
                         }

    }];
}

-(void) zoomForScale:(CGFloat)scale AtPoint:(CGPoint)point {
    if ([self isPointInsideMediaView:point]) {
        //the point is inside the media view
        if (scale >= self.scrollView.minimumZoomScale && scale <= self.scrollView.maximumZoomScale) {
            CGFloat k = scale/self.scrollView.minimumZoomScale;
            CGPoint pointInMediaView = [self.scrollView convertPoint:point toView:self.mediaView];
            CGFloat x = pointInMediaView.x*scale;
            CGFloat y = pointInMediaView.y*scale;
            CGFloat width = self.frame.size.width;
            CGFloat height = self.frame.size.height;
            CGFloat mediaWidth = self.mediaView.frame.size.width;
            CGFloat mediaHeight = self.mediaView.frame.size.height;
            
            CGFloat xOffset = MIN(x - width/2, mediaWidth*k - width);
            xOffset = MAX(0, xOffset);
            CGFloat yOffset = MIN(y - height/2, mediaHeight*k - height);
            yOffset = MAX(0, yOffset);
            
            self.scrollView.zoomScale = scale;
            self.scrollView.contentOffset = CGPointMake(xOffset, yOffset);
        }
    }
}

-(BOOL) isPointInsideMediaView:(CGPoint)point {
    if (self.mediaView.frame.size.width < self.scrollView.frame.size.width) {
        CGFloat xOrigine = self.mediaView.frame.origin.x;
        CGFloat width = self.mediaView.frame.size.width;
        if (point.x < xOrigine || point.x > xOrigine + width) {
            return NO;
        }
    }
    
    if (self.mediaView.frame.size.height < self.scrollView.frame.size.height) {
        CGFloat yOrigine = self.mediaView.frame.origin.y;
        CGFloat height = self.mediaView.frame.size.height;
        if (point.y < yOrigine || point.y > yOrigine + height) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - VideoSliderDelegate

-(void)didChangePositionBar:(CMTime)newTime forValue:(CGFloat)value {
    if (self.mediaIsAnImage) {
        return;
    }
    
    VideoPlayerView *playerView = (VideoPlayerView *)self.mediaView;
    
    if (playerView.isPlaying) {
        [playerView.moviePlayer pause];
    }
    
    //[playerView.moviePlayer seekToTime:newTime];
    [playerView seekSmoothlyToTime:newTime];
}

-(void)stoppedChangingPositionBar:(CMTime)finalTime {
    if (self.mediaIsAnImage) {
        return;
    }
    
    VideoPlayerView *playerView = (VideoPlayerView *)self.mediaView;
    
    if (playerView.isPlaying) {
        [playerView.moviePlayer play];
    }
}

#pragma mark - UIScrollView Delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mediaView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateMediaViewOrigineForSize:self.scrollView.frame.size];
}
@end
