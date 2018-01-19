//
//  PictureViewController.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 28/06/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "PictureViewController.h"
#define INTERITEM_SPACING 30

#import "ImageOpeningDismisser.h"

@interface PictureViewController () {
    //if yes performe animation when scrolling between image and video cell
    BOOL animation;
    CGFloat startOffset;
    
    BOOL willDisplayFirstCell;
}
@end

@implementation PictureViewController

#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    flmgr = [FilesManager sharedFilesMgr];
    animation = NO;
    willDisplayFirstCell = YES;
    
    //setup views
    [self setupCollectionView];
    [self setupToolbar];
    [self setupSubviews];
    
    //gesture recognition
    self.singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.collectionView addGestureRecognizer:self.singleTapGestureRecognizer];
    
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.collectionView addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set outself as the navigation controller's delegate so we're asked for a transitioning object
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
    
    // If a video is playing, stop it
    self.currentIndex = [self getCurrentIndex];
    if (self.medias.count != 0) {
        NSDictionary *media = [self.medias objectAtIndex:self.currentIndex];
        if ([[media objectForKey:@"mediaType"] isEqualToString:@"video"]) {
            VideoPlayerView *playerView = (VideoPlayerView *)((GalleryCollectionViewCell *)self.collectionView.visibleCells.firstObject).mediaView;
            if (playerView.isPlaying) {
                NSLog(@"stop");
                [playerView pause];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setup methods

-(void)setupCollectionView {
    
    [self.collectionView registerClass:[GalleryCollectionViewCell class] forCellWithReuseIdentifier:@"galleryCell"];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self displayCellAtIndex:self.currentIndex];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void) setupToolbar {
    UIButton *trashButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    trashButton.frame = CGRectMake(0, 0, 30, 30);
    [trashButton setBackgroundImage:[UIImage imageNamed:@"delete_blue.png"] forState:UIControlStateNormal];
    [trashButton addTarget:self action:@selector(deleteCurrentMedia:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playPauseButton.frame = CGRectMake(0, 0, 25, 25);
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateSelected];
    [playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    playPauseButton.hidden = YES;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    self.toolbarTrashButton = [[UIBarButtonItem alloc] initWithCustomView:trashButton];
    self.toolbarPlayPauseButton = [[UIBarButtonItem alloc] initWithCustomView:playPauseButton];
    [self.toolbar setItems:@[self.toolbarPlayPauseButton, flexibleSpace, self.toolbarTrashButton] animated:NO];
}

-(void)setupSubviews {
    //slider
    self.slider.hidden = YES;
    
    //interItemSpacingView
    CGRect SpacingViewFrame = CGRectMake(-INTERITEM_SPACING, 0.0, INTERITEM_SPACING, self.view.frame.size.height);
    self.interItemSpacingView = [[UIView alloc] initWithFrame:SpacingViewFrame];
    self.interItemSpacingView.backgroundColor = self.collectionView.backgroundColor;
    [self.view insertSubview:self.interItemSpacingView belowSubview:self.slider];
    
    //Play button
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.playButton setTag:111];
    self.playButton.bounds = CGRectMake(0, 0, 70, 70);
    self.playButton.center = self.view.center;
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play-button.png"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.hidden = NO;
    [self.view addSubview:self.playButton];
}


#pragma mark - Gesture recognition

- (void) handleSingleTap:(UITapGestureRecognizer *) sender {
    if (self.toolbar.hidden) {
        [self showBars];
    }else {
        [self hideBars];
    }
}

- (void) handleDoubleTap:(UITapGestureRecognizer *) sender {
    GalleryCollectionViewCell *currentCell = (GalleryCollectionViewCell *)self.collectionView.visibleCells.firstObject;
    [currentCell doubleTapAtPoint:[sender locationInView:self.view]];
}


-(void) hideBars {
    if (self.toolbar.hidden && self.navigationController.navigationBar.hidden) {
        return;
    }
    
    CGRect navbarFinalFrame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,
                                         -self.navigationController.navigationBar.frame.size.height,
                                         self.navigationController.navigationBar.frame.size.width,
                                         self.navigationController.navigationBar.frame.size.height);
    
    [self.view removeConstraint:self.toolbarBottomConstraint];
    CGFloat constant = (self.toolbar.frame.size.height + self.slider.frame.size.height);
    self.toolbarBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:0 toItem:self.toolbar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1
                                                                 constant:-constant];
    [self.view addConstraint:self.toolbarBottomConstraint];
    
    [UIView animateWithDuration:0.16
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.navigationController.navigationBar.frame = navbarFinalFrame;
                     }
                     completion:^(BOOL finished) {
                         self.toolbar.hidden = YES;
                         self.navigationController.navigationBar.hidden = YES;
                     }
     ];
    
}

-(void) showBars {
    if (!self.toolbar.hidden && !self.navigationController.navigationBar.hidden) {
        return;
    }
    
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGRect statusBarWindowRect = [self.view.window convertRect:statusBarFrame fromWindow: nil];
    CGRect statusBarViewRect = [self.view convertRect:statusBarWindowRect fromView: nil];
    CGRect navbarFinalFrame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,
                                         statusBarViewRect.size.height,
                                         self.navigationController.navigationBar.frame.size.width,
                                         self.navigationController.navigationBar.frame.size.height);
    
    
    [self.view removeConstraint:self.toolbarBottomConstraint];
    self.toolbarBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:0 toItem:self.toolbar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1
                                                                 constant:0.0];
    [self.view addConstraint:self.toolbarBottomConstraint];
    
    self.toolbar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    [UIView animateWithDuration:0.16
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.navigationController.navigationBar.frame = navbarFinalFrame;
                     }
     ];
}


#pragma mark - UICollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.medias count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *media = [self.medias objectAtIndex:indexPath.row];
    
    GalleryCollectionViewCell *galleryCell = (GalleryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
    
    galleryCell.media = media;
    [galleryCell updateCell];
    
    return galleryCell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

-(CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    CGSize currentSize = self.collectionView.frame.size;
    float offset = self.currentIndex * currentSize.width;
    return CGPointMake(offset, 0);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GalleryCollectionViewCell *futureCell = (GalleryCollectionViewCell *)cell;
    GalleryCollectionViewCell *currentCell = (GalleryCollectionViewCell *)self.collectionView.visibleCells.firstObject;
    
    animation = YES;
    startOffset = currentCell.frame.origin.x;
    
    if (willDisplayFirstCell) {
        self.slider.delegate = futureCell;
        willDisplayFirstCell = NO;
    }
    
    [futureCell resetForSize:self.view.frame.size];
    if (!futureCell.mediaIsAnImage) {
        VideoPlayerView *playerView = (VideoPlayerView *)futureCell.mediaView;
        [playerView reset];
    }
    
    if (futureCell.mediaIsAnImage) {
        self.playButton.hidden = YES;
    }
}

- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    animation = NO;
    self.slider.alpha = 1.0;
    self.toolbarPlayPauseButton.customView.alpha = 1.0;
    
    GalleryCollectionViewCell *previousCell = (GalleryCollectionViewCell*)cell;
    GalleryCollectionViewCell *currentCell = (GalleryCollectionViewCell*)self.collectionView.visibleCells.firstObject;
    
    //stop playing video on the previous cell
    if (!previousCell.mediaIsAnImage) {
        VideoPlayerView *previousPlayerView =  (VideoPlayerView *)previousCell.mediaView;
        if (previousPlayerView.videoHasBegin) {
            [previousPlayerView pause];
            [previousPlayerView.moviePlayer removeTimeObserver:self.playbackObserver];
        }
    }
    
    if (!currentCell.mediaIsAnImage) {
        VideoPlayerView *playerView =  (VideoPlayerView *)currentCell.mediaView;
        if (!playerView.videoHasBegin) {
            self.playButton.hidden = NO;
            self.toolbarPlayPauseButton.customView.hidden = YES;
            self.slider.hidden = YES;
            self.slider.value = 0.0;
            
            NSURL * videoURL = [NSURL fileURLWithPath:[currentCell.media objectForKey:@"videoPath"]];
            [self.slider setUrl:videoURL];
            self.slider.delegate = currentCell;
        }
    }else {
        self.toolbarPlayPauseButton.customView.hidden = YES;
        self.slider.hidden = YES;
    }
}

//to make the interItemSpacingView moving with the cells during scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat x = self.collectionView.frame.size.width - fmod([self.collectionView contentOffset].x, self.collectionView.frame.size.width);
    CGFloat epsilon = (x/self.collectionView.frame.size.width)*INTERITEM_SPACING - INTERITEM_SPACING/2;
    x += epsilon;
    self.interItemSpacingView.center = CGPointMake(x, self.interItemSpacingView.center.y);
    
    if (animation) {
        CGFloat alpha = 1 - fabs([self.collectionView contentOffset].x - startOffset)/self.collectionView.frame.size.width;
        self.slider.alpha = alpha;
        self.toolbarPlayPauseButton.customView.alpha = alpha;
    }
}


-(void) displayCellAtIndex:(NSInteger) index {
    CGSize currentSize = self.collectionView.frame.size;
    float offset = index * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
}


#pragma mark - Rotation handling methods

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // Before rotation
    
    // Suppress the layout errors by invalidating the layout
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.interItemSpacingView setAlpha:0.0];
    self.currentIndex = [self getCurrentIndex];
    
    BOOL anim = animation;
    animation = NO;
    GalleryCollectionViewCell *currentCell = self.collectionView.visibleCells.firstObject;
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        
        // During rotation
        [currentCell resetForSize:size];
        self.playButton.center = self.view.center;
    } completion:^(id  _Nonnull context) {
        
        // After rotation
        //reset the frame of the interitemsapcing view
        self.interItemSpacingView.frame = CGRectMake(-INTERITEM_SPACING, 0.0, INTERITEM_SPACING, size.height);
        [self.interItemSpacingView setAlpha:1.0];
        animation = anim;
    }];
}

// Calculate the index of the item that the collectionView is currently displaying
- (NSInteger) getCurrentIndex {
    CGPoint currentOffset = [self.collectionView contentOffset];
    NSInteger currentIndex = currentOffset.x / self.collectionView.frame.size.width;
    
    return currentIndex;
}



#pragma mark - action methods

//when the user click on a play button
-(void)playButtonAction:(UIButton*)sender
{
    GalleryCollectionViewCell *currentCell = (GalleryCollectionViewCell *)self.collectionView.visibleCells.firstObject;
    
    //Be sure that the media is a video
    if (!currentCell.mediaIsAnImage) {
        VideoPlayerView *playerView = (VideoPlayerView *)currentCell.mediaView;
        
        //the button clicked is the big play button ton start the video
        if(sender.tag == 111) {
            sender.hidden = YES;
            [self hideBars];
            self.toolbarPlayPauseButton.customView.hidden = NO;
            self.slider.hidden = NO;
            
            if (playerView.videoHasBegin) {
                [playerView reset];
            }
            
            //Init playbackObserver 
            [self initPlaybackObserverForPlayerView:playerView];
        }
        
        if (playerView.isPlaying) {
            [playerView pause];
            [(UIButton*)self.toolbarPlayPauseButton.customView setSelected:NO];
        } else {
            [playerView play];
            [(UIButton*)self.toolbarPlayPauseButton.customView setSelected:YES];
        }
    }
}

-(void) initPlaybackObserverForPlayerView:(VideoPlayerView *) playerView {
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(playerView) weakPlayerView = playerView;
    __weak __typeof(self) weakself = self;
    self.playbackObserver = [playerView.moviePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        
        if (weakself.slider.userIsDragging) {
            if (weakPlayerView.finishPlaying && weakself.slider.value != 1.0) {
                weakPlayerView.finishPlaying = NO;
                self.toolbarPlayPauseButton.customView.hidden = NO;
                self.playButton.hidden = YES;
            }
        }else {
            CMTime endTime = CMTimeConvertScale (weakPlayerView.moviePlayer.currentItem.asset.duration,
                                                 weakPlayerView.moviePlayer.currentTime.timescale,
                                                 kCMTimeRoundingMethod_RoundHalfAwayFromZero);
            
            if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
                [weakself.slider seekToTime:weakPlayerView.moviePlayer.currentTime];
            }
            if (weakPlayerView.finishPlaying) {
                weakself.toolbarPlayPauseButton.customView.hidden = YES;
                weakself.playButton.hidden = NO;
            }
        }
    }];
}

- (void)deleteCurrentMedia:(UIButton*)sender {
    self.currentIndex = [self getCurrentIndex];
    NSDictionary *media = [self.medias objectAtIndex:self.currentIndex];
    NSString *mediaType = (NSString *)[media objectForKey:@"mediaType"];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:[NSString stringWithFormat:@"Cette %@ sera supprimée définitivement",mediaType]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Supprimer la %@",mediaType]
                                                           style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              [self deleteCurrentMediaWithAnimation];
                                                          }];
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Annuler"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)deleteCurrentMediaWithAnimation {
    
    //if we deleted the last media
    if (self.medias.count == 1) {
        
        //Delete the media from the memory
        [flmgr deleteMediaWithPersonIndex:self.personIndex andMediaIndex:self.currentIndex];
        
        //Delete the media from this view controller
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:self.medias];
        [mutableArray removeObjectAtIndex:self.currentIndex];
        self.medias = [mutableArray copy];
        
        //Delete the media from the parent view controller
        self.detailViewController.medias = self.medias;
        
        //reload the collectionView datas
        [self.collectionView reloadData];
        
        //reload the detailViewController's collectionView data
        [self.detailViewController.collectionView reloadData];
        [self.detailViewController resetCollectionViewLayout];
        
        //navigate back
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    
    
    /////prerequisits for the animation/////
    NSInteger futureCellIndex;
    CGRect futureCellInitialFrame = self.collectionView.bounds;
    futureCellInitialFrame.origin.x = self.collectionView.frame.size.width;
    if (self.currentIndex == self.medias.count - 1) {
        futureCellIndex = self.currentIndex - 1;
        futureCellInitialFrame.origin.x = - self.collectionView.frame.size.width;
    }else {
        futureCellIndex = self.currentIndex + 1;
        futureCellInitialFrame.origin.x = self.collectionView.frame.size.width;
    }
    
    UIView *animationWrapperView = [[UIView alloc] initWithFrame:self.collectionView.frame];
    animationWrapperView.backgroundColor = self.collectionView.backgroundColor;
    animationWrapperView.clipsToBounds = YES;
    
    UIImage *currentCellImage = (UIImage *)[[self.medias objectAtIndex:self.currentIndex] objectForKey:@"image"];
    UIImageView *currentCellView = [[UIImageView alloc] initWithFrame:self.collectionView.frame];
    currentCellView.contentMode = UIViewContentModeScaleAspectFit;
    [currentCellView setImage:currentCellImage];
    
    UIImage *futureCellImage = (UIImage *)[[self.medias objectAtIndex:futureCellIndex] objectForKey:@"image"];
    UIImageView *futureCellView = [[UIImageView alloc] initWithFrame:futureCellInitialFrame];
    futureCellView.contentMode = UIViewContentModeScaleAspectFit;
    [futureCellView setImage:futureCellImage];
    
    [animationWrapperView addSubview:currentCellView];
    [animationWrapperView addSubview:futureCellView];
    
    [self.view insertSubview:animationWrapperView aboveSubview:self.collectionView];
    
    
    
    /////delete what has to be deleted//////
    
    //Delete the media from the memory
    [flmgr deleteMediaWithPersonIndex:self.personIndex andMediaIndex:self.currentIndex];
    
    //Delete the media from this view controller
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:self.medias];
    [mutableArray removeObjectAtIndex:self.currentIndex];
    self.medias = [mutableArray copy];
    
    //Delete the media from the parent view controller
    self.detailViewController.medias = self.medias;
    
    //reload the collectionView datas
    [self.collectionView reloadData];
    
    
    
    ///////perform animation///////
    [UIView animateKeyframesWithDuration:0.4
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:1/2.0
                                                                animations:^{
                                                                    currentCellView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
                                                                    currentCellView.center = animationWrapperView.center;
                                                                    currentCellView.alpha = 0.0f;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:1/2.0
                                                          relativeDuration:1/2.0
                                                                animations:^{
                                                                    futureCellView.center = animationWrapperView.center;
                                                                }];
                              }
                              completion:^(BOOL finished) {
                                  
                                  [animationWrapperView removeFromSuperview];
                                  
                                  //reload the detailViewController's collectionView data
                                  [self.detailViewController.collectionView reloadData];
                                  [self.detailViewController resetCollectionViewLayout];
                              }];
}

#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a CqtDetailViewController
    if (fromVC == self && [toVC isKindOfClass:[CqtDetailViewController class]] && self.medias.count !=0) {
        return [[ImageOpeningDismisser alloc] init];
    }
    else {
        return nil;
    }
}


@end
