//
//  ImageOpeningDismisser.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 23/07/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "ImageOpeningDismisser.h"
#import "PictureViewController.h"

@implementation ImageOpeningDismisser

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    PictureViewController *fromViewController = (PictureViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CqtDetailViewController *toViewController = (CqtDetailViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    //[detailViewController.view layoutSubviews];
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
    NSInteger mediaIndex = [fromViewController getCurrentIndex];
    NSDictionary *media = [toViewController.medias objectAtIndex:mediaIndex];
    UIImage *image = [media objectForKey:@"image"];
    
    
    /* Get all the desired frames */
    
    float imageRatio = image.size.height/image.size.width;
    float screenRatio = fromViewController.view.frame.size.height/fromViewController.view.frame.size.width;
    
    //Get the frame of the image as it's dispayed in the PictureVC (wrapperView initial frame)
    CGFloat wIwidth;
    CGFloat wIheight;
    CGFloat wIx;
    CGFloat wIy;
    if (imageRatio >= screenRatio) {
        wIheight = fromViewController.view.frame.size.height;
        wIwidth = wIheight/imageRatio;
        wIx = (fromViewController.view.frame.size.width - wIwidth)/2;
        wIy = 0.0;
        
    }else {
        wIwidth = fromViewController.view.frame.size.width;
        wIheight = wIwidth*imageRatio;
        wIx = 0.0;
        wIy = (fromViewController.view.frame.size.height - wIheight)/2;
    }
    
    CGRect wrapperInitialFrame = CGRectMake(wIx, wIy, wIwidth, wIheight);
    
    //Get the frame of the cell in the DetailVC View (wrapperView final frame)
    [toViewController.collectionView layoutIfNeeded];
    NSIndexPath *indexPathForImage = [NSIndexPath indexPathForItem:mediaIndex inSection:1];
    UICollectionViewCell *targetVCCell = [toViewController.collectionView cellForItemAtIndexPath:indexPathForImage];
    CGRect wrapperFinalFrame = [toViewController.view convertRect:targetVCCell.frame fromView:toViewController.collectionView];
    
    //Calculate the imageView initial frame
    CGRect imageViewInitialFrame = CGRectMake(0.0, 0.0, wIwidth, wIheight);
    
    //Calculate the imageView final frame
    CGFloat iFwidth;
    CGFloat iFheight;
    CGFloat iFx;
    CGFloat iFy;
    if (imageRatio >= 1) {
        iFwidth = wrapperFinalFrame.size.width;
        iFheight = iFwidth*imageRatio;
        iFx = 0.0;
        iFy = (wrapperFinalFrame.size.height - iFheight)/2;
        
    }else {
        iFheight = wrapperFinalFrame.size.height;
        iFwidth =  iFheight/imageRatio;
        iFx = (wrapperFinalFrame.size.width - iFwidth)/2;
        iFy = 0.0;
    }
    
    CGRect imageViewFinalFrame = CGRectMake(iFx, iFy, iFwidth, iFheight);
    
    
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:wrapperInitialFrame];
    wrapperView.backgroundColor = [UIColor clearColor];
    wrapperView.clipsToBounds = YES;
    wrapperView.layer.cornerRadius = targetVCCell.layer.cornerRadius;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = imageViewInitialFrame;
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    [wrapperView addSubview:imageView];
    [containerView addSubview:wrapperView];
    
    UIView *blackBackgroundView = [[UIView alloc] initWithFrame:toViewController.view.frame];
    blackBackgroundView.backgroundColor = [UIColor whiteColor];
    blackBackgroundView.alpha = 1.0;
    [containerView insertSubview:blackBackgroundView belowSubview:wrapperView];
    [containerView insertSubview:toViewController.view belowSubview:blackBackgroundView];
    
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         wrapperView.frame = wrapperFinalFrame;
                         imageView.frame = imageViewFinalFrame;
                         blackBackgroundView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [wrapperView removeFromSuperview];
                         [blackBackgroundView removeFromSuperview];
                         [transitionContext completeTransition:true];
                     }
     ];
    
}

@end
