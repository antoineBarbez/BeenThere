//
//  PictureViewController.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 28/06/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryCollectionViewCell.h"
#import "CqtDetailViewController.h"
#import "FilesManager.h"
#import "VideoSlider.h"




@interface PictureViewController : UIViewController <UINavigationControllerDelegate,
                                                        UICollectionViewDataSource,
                                                        UICollectionViewDelegate
>
{
    FilesManager *flmgr;
}


@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIView *interItemSpacingView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIView *toolbarContainerView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (strong, nonatomic) UIBarButtonItem *toolbarPlayPauseButton;
@property (strong, nonatomic) IBOutlet VideoSlider *slider;

@property (strong, nonatomic) NSArray *medias;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSInteger personIndex;

@property (strong, nonatomic) CqtDetailViewController *detailViewController;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (weak, nonatomic) id playbackObserver;

- (IBAction)toolbarTrashButton:(id)sender;

- (NSInteger) getCurrentIndex;

@end
