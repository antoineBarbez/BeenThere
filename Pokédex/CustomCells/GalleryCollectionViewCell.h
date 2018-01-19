//
//  GalleryCollectionViewCell.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 29/06/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerView.h"
#import "VideoSliderDelegate.h"

@interface GalleryCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate, VideoSliderDelegate>

@property (assign, nonatomic) BOOL mediaIsAnImage;
@property (strong, nonatomic) NSDictionary *media;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *mediaView;

-(void) doubleTapAtPoint:(CGPoint)point;
-(void) resetForSize:(CGSize) size;
-(void)updateCell;
@end
