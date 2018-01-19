//
//  ImageOpeningPresenter.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 23/07/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "ImageOpeningPresenter.h"
#import "CqtDetailViewController.h"
#import "PictureViewController.h"

@implementation ImageOpeningPresenter

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CqtDetailViewController *fromViewController = (CqtDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PictureViewController *toViewController = (PictureViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
    
    NSIndexPath *selectedIndexPath = [[fromViewController.collectionView indexPathsForSelectedItems] firstObject];
    UICollectionViewCell *selectedCell = [fromViewController.collectionView cellForItemAtIndexPath:selectedIndexPath];
    NSDictionary *media = [fromViewController.medias objectAtIndex:selectedIndexPath.row];
    UIImage *selectedImage = [media objectForKey:@"image"];
    
    /* Get all the desired frames */
    
    float imageRatio = selectedImage.size.height/selectedImage.size.width;
    float screenRatio = toViewController.view.frame.size.height/toViewController.view.frame.size.width;
    
    //Get the frame of the cell in the VC View (wrapperView initial frame)
    CGRect wrapperInitialFrame = [fromViewController.view convertRect:selectedCell.frame fromView:fromViewController.collectionView];
    
    //Get the frame of the image as it's dispayed in the PictureVC (wrapperView final frame)
    CGFloat wFwidth;
    CGFloat wFheight;
    CGFloat wFx;
    CGFloat wFy;
    if (imageRatio >= screenRatio) {
        wFheight = toViewController.view.frame.size.height;
        wFwidth = wFheight/imageRatio;
        wFx = (toViewController.view.frame.size.width - wFwidth)/2;
        wFy = 0.0;
        
    }else {
        wFwidth =  toViewController.view.frame.size.width;
        wFheight = wFwidth*imageRatio;
        wFx = 0.0;
        wFy = (toViewController.view.frame.size.height - wFheight)/2;
    }
    
    CGRect wrapperFinalFrame = CGRectMake(wFx, wFy, wFwidth, wFheight);
    
    //Calculate the imageView initial frame
    CGFloat iIwidth;
    CGFloat iIheight;
    CGFloat iIx;
    CGFloat iIy;
    if (imageRatio >= 1) {
        iIwidth = wrapperInitialFrame.size.width;
        iIheight = iIwidth*imageRatio;
        iIx = 0.0;
        iIy = (wrapperInitialFrame.size.height - iIheight)/2;
        
    }else {
        iIheight = wrapperInitialFrame.size.height;
        iIwidth =  iIheight/imageRatio;
        iIx = (wrapperInitialFrame.size.width - iIwidth)/2;
        iIy = 0.0;
    }
    
    CGRect imageViewinitialFrame = CGRectMake(iIx, iIy, iIwidth, iIheight);
    
    //Calculate the imageView final frame
    CGRect imageViewFinalFrame = CGRectMake(0.0, 0.0, wFwidth, wFheight);
    
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:wrapperInitialFrame];
    wrapperView.backgroundColor = [UIColor clearColor];
    wrapperView.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:selectedImage];
    imageView.frame = imageViewinitialFrame;
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    [wrapperView addSubview:imageView];
    [containerView addSubview:wrapperView];
    
    
    UIView *blackBackgroundView = [[UIView alloc] initWithFrame:fromViewController.view.frame];
    blackBackgroundView.backgroundColor = [UIColor whiteColor];
    blackBackgroundView.alpha = 0.0;
    [containerView insertSubview:blackBackgroundView belowSubview:wrapperView];
    
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         wrapperView.frame = wrapperFinalFrame;
                         imageView.frame = imageViewFinalFrame;
                         blackBackgroundView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [containerView addSubview:toViewController.view];
                         
                         [transitionContext completeTransition:true];
                         
                         if ([[media objectForKey:@"mediaType"] isEqualToString:@"video"]) {
                             NSURL * videoURL = [NSURL fileURLWithPath:[media objectForKey:@"videoPath"]];
                             [toViewController.slider setUrl:videoURL];
                         }
                     }
     ];
}
@end
