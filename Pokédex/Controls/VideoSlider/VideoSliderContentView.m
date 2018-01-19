//
//  VideoSliderContentView.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 27/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "VideoSliderContentView.h"

@interface VideoSliderContentView ()
{
    AVAssetImageGenerator *generator;
}

@end

@implementation VideoSliderContentView

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
}

-(void)regenerateThumbnailsForAsset:(AVAsset *)asset {
    if (asset == nil) {
        return;
    }
    
    [generator cancelAllCGImageGeneration];
    
    NSArray<NSValue *> *times = [self getThumbnailTimesForAsset:asset];
    [self generateImagesForAsset:asset atTimes:times];
    
}

-(NSArray<NSValue *> *) getThumbnailTimesForAsset:(AVAsset *)asset {
    NSMutableArray *times = [[NSMutableArray alloc] init];
    
    
    CMTime duration = [asset duration];
    NSInteger secondsValue = ceil(duration.value/duration.timescale);
    
    if (secondsValue < 4) {
        CMTime requestedTime = CMTimeMake(1, 60);
        NSValue *nsValue = [NSValue valueWithCMTime:requestedTime];
        
        for (int i=0; i<10; i++) {
            [times addObject:nsValue];
        }
    }else {
        CGFloat interval =((CGFloat)(secondsValue-2)/9);
        for (int i=0; i<10; i++) {
            CMTime requestedTime = CMTimeMakeWithSeconds(1+i*interval, 6000);
            NSValue *nsValue = [NSValue valueWithCMTime:requestedTime];
            
            [times addObject:nsValue];
        }
    }
    
    return times;
}

-(void)displayImages:(NSArray<UIImage *> *)images {
    if (images.count != 10) {
        return;
    }
    
    [self.imageView1 setImage:[images objectAtIndex:0]];
    [self.imageView2 setImage:[images objectAtIndex:1]];
    [self.imageView3 setImage:[images objectAtIndex:2]];
    [self.imageView4 setImage:[images objectAtIndex:3]];
    [self.imageView5 setImage:[images objectAtIndex:4]];
    [self.imageView6 setImage:[images objectAtIndex:5]];
    [self.imageView7 setImage:[images objectAtIndex:6]];
    [self.imageView8 setImage:[images objectAtIndex:7]];
    [self.imageView9 setImage:[images objectAtIndex:8]];
    [self.imageView10 setImage:[images objectAtIndex:9]];
}

-(void)generateImagesForAsset:(AVAsset *)asset atTimes:(NSArray<NSValue *> *)times {
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES; // To make the thumbnail well oriented (portrait/landscape)
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }else{
            UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:im];
            [images addObject:thumbnailImage];
            
            if (images.count == 10) {
                [self performSelectorOnMainThread:@selector(displayImages:) withObject:images  waitUntilDone:NO];
            }
        }
    };
    
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}



@end
