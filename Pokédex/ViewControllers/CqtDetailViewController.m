//
//  CqtDetailViewController.m
//  Pokédex
//
//  Created by Antoine Barbez on 08/10/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "CqtDetailViewController.h"
#import "PictureViewController.h"
#import "CollectionViewCell.h"
#import "TopCollectionViewCell.h"

#import "ImageOpeningPresenter.h"


@interface CqtDetailViewController () {
    float previousScrollViewYOffset;
    CGFloat itemsize;
    CGFloat interItemSpacing;
    CGFloat keyboardHeight;
    CGSize contentSize;
}


@end

@implementation CqtDetailViewController


#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    flmgr = [FilesManager sharedFilesMgr];
    
    
    self.topView.name.text = [NSString stringWithFormat:@"%@ %@",self.person.firstname, self.person.lastname];
    //self.country.text = self.person.country.frenchName;
    //[self.flag setImage:[self.person.country getFlag]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //Set the collection view
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.medias = [flmgr getMediasWithMediaNames:self.person.medias];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TopCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HeaderCell"];
    
    
    
    CGFloat portraitWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    interItemSpacing = portraitWidth/80;
    
    //unhide the tabBar
    CGRect tabBraFrame = self.tabBarController.tabBar.frame;
    if (tabBraFrame.origin.y != (self.view.frame.size.height - tabBraFrame.size.height)) {
        tabBraFrame.origin.y = self.view.frame.size.height - tabBraFrame.size.height;
        [self.tabBarController.tabBar setFrame:tabBraFrame];
    }
    
    [self resetCollectionViewLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Make the navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.tabBarController.tabBar.hidden  = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set self as the navigation controller's delegate so we're asked for a transitioning object
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)viewDidLayoutSubviews {
    CGRect addPictureFrame =  self.addPicture.frame;
    addPictureFrame.origin.y = self.tabBarController.tabBar.frame.origin.y - 18 - addPictureFrame.size.height;
    [self.addPicture setFrame:addPictureFrame];
    
    [self resetCollectionViewLayout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)reloadDataWithPersonIndex:(NSInteger)personIndex {
    NSDictionary *person = [flmgr getPersonForIndex:personIndex];
    
    self.person = [[Person alloc] initWithDictionary:person];
    self.topView.name.text = [NSString stringWithFormat:@"%@ %@",self.person.firstname, self.person.lastname];
    //self.country.text = self.person.country.frenchName;
    //[self.flag setImage:[self.person.country getFlag]];
    
    self.medias = [flmgr getMediasWithMediaNames:self.person.medias];
    [self.collectionView reloadData];
}

- (void) resetCollectionViewLayout {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    //calculate the size of the photo items
    NSInteger nbItemPerLine;
    if (self.view.frame.size.width < self.view.frame.size.height) {
        //Portrait
        nbItemPerLine = 3;
    }else {
        //Landscape
        nbItemPerLine = 5;
    }
    itemsize = (self.collectionView.frame.size.width - (nbItemPerLine + 1)*interItemSpacing)/nbItemPerLine;
    
    [collectionViewLayout invalidateLayout];
}





#pragma mark - Rotation handling methods

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // Before rotation
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        // During rotation
        if (size.height < 500 && self.topView.frame.size.height > self.topView.minHeight) {
            CGRect frame = self.topView.frame;
            CGPoint contentOffset = self.collectionView.contentOffset;
            frame.size.height = self.topView.minHeight;
            contentOffset.y = self.topView.maxHeight - self.topView.minHeight;
            [self.topView setFrame:frame];
            [self.collectionView setContentOffset:contentOffset];
        }
    } completion:^(id  _Nonnull context) {
        
        // After rotation
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
- (IBAction)delete:(id)sender {
    [self.flmgr deletePersonWithIndex:self.personIndex];
    
    [self.listeViewController.table_view reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPicture"]) {
        
        PictureViewController *destViewController = segue.destinationViewController;
        
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        destViewController.medias = self.medias;
        destViewController.currentIndex = indexPath.row;
        destViewController.personIndex = [self.person.index integerValue];
        destViewController.detailViewController = self;
        
        //[self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}


#pragma mark - UIImagePickerController

- (IBAction)addPicture:(id)sender {
    [self showImagePicker];
}

- (void)showImagePicker {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = imagePickerController.popoverPresentationController;
    
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    
    self.imagePickerController = imagePickerController; // we need this for later
    
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]){
        //An image has been selected
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
        [flmgr addPicture:imageData forPersonIndex:[self.person.index integerValue]];
        
    }else if ([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]){
        
        //A video has been selected
        NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
        [flmgr addVideo:videoURL forPersonIndex:[self.person.index integerValue]];
        
    }
    
    [self reloadDataWithPersonIndex:[self.person.index integerValue]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
}



#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.medias.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        NSString *identifier = @"HeaderCell";
        
        TopCollectionViewCell *headerCell = (TopCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        headerCell.textView.placeholder = @"Notes";
        headerCell.textView.backgroundColor = [UIColor whiteColor];
        [headerCell.textView setText:self.person.note];
        headerCell.textView.delegate = self;
        
        return headerCell;
    }else {
        NSString *identifier = @"Cell";
        
        CollectionViewCell *cell = (CollectionViewCell* )[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        NSDictionary *media = [self.medias objectAtIndex:indexPath.row];
        
        if ([[media objectForKey:@"mediaType"] isEqualToString:@"video"]) {
            NSString *duration = [media objectForKey:@"duration"];
            cell.label.hidden = NO;
            cell.label.text = duration;
        }else {
            cell.label.hidden = YES;
        }
        
        UIImageView *imageView = cell.imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [media objectForKey:@"image"];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 6;
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:@"headerId"
                                                     forIndexPath:indexPath];
}


#pragma mark - UICollectionViewLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(0.0, self.topView.maxHeight);
    }else {
        return CGSizeMake(0.0, interItemSpacing);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TopCollectionViewCell *cell = [TopCollectionViewCell fromNib];
        
        [cell.textView setText:self.person.note];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        size.width = self.collectionView.frame.size.width;
    
        return size;
    }else {
        return CGSizeMake(itemsize, itemsize);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 0;
    }else {
        return interItemSpacing - 0.1;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 0;
    }else {
        return interItemSpacing;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        UIEdgeInsets firstSectionInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        return firstSectionInsets;
    }else {
        CGFloat firstSectionHeight = [self collectionView:collectionView
                                                   layout:collectionViewLayout
                                   sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                              inSection:0]].height;
        float nbOfLinesInSecondSection = ceil(self.medias.count*(itemsize + interItemSpacing)/(self.collectionView.frame.size.width - interItemSpacing));
        
        CGFloat secondSectionHeight = nbOfLinesInSecondSection*itemsize + (nbOfLinesInSecondSection - 1)*interItemSpacing;
        
        CGFloat bottomInset = MAX(0.0, self.view.frame.size.height - self.topView.minHeight -
                                  (self.topView.maxHeight + firstSectionHeight + secondSectionHeight) + self.topView.maxHeight);
        UIEdgeInsets galleryInsets = UIEdgeInsetsMake(0.0, interItemSpacing, bottomInset, interItemSpacing);
        
        return galleryInsets;
    }
}


#pragma mark - handle scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    CGFloat ytabBarUp = self.view.frame.size.height - tabBarFrame.size.height;
    
    CGRect topViewFrame = self.topView.frame;
    
    if (scrollOffset <= -self.collectionView.contentInset.top) {
        //user scroll down more than the maximum
        tabBarFrame.origin.y = ytabBarUp;
        topViewFrame.size.height = self.topView.maxHeight;
        
    }else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        //user scroll up more than the maximum
        tabBarFrame.origin.y = self.view.frame.size.height;
        topViewFrame.size.height = self.topView.minHeight;
    }else {
        tabBarFrame.origin.y = MIN(self.view.frame.size.height, MAX(ytabBarUp, tabBarFrame.origin.y + scrollDiff));
        
        topViewFrame.size.height = MIN(self.topView.maxHeight, MAX(self.topView.minHeight,self.topView.maxHeight - scrollOffset ));
    }
    
    CGRect addPictureFrame = self.addPicture.frame;
    addPictureFrame.origin.y = tabBarFrame.origin.y - 18 - addPictureFrame.size.height;
    [self.addPicture setFrame:addPictureFrame];
    
    [self.tabBarController.tabBar setFrame:tabBarFrame];
    [self.topView setFrame:topViewFrame];
    
    previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    CGRect topViewFrame = self.topView.frame;
    if (tabBarFrame.origin.y > (self.view.frame.size.height - tabBarFrame.size.height)) {
        [self animateTabBarTo:self.view.frame.size.height];
    }
    
    if (topViewFrame.size.height < (self.topView.maxHeight + self.topView.minHeight)/2 && topViewFrame.size.height != self.topView.minHeight) {
        [self animateTopViewTo:self.topView.maxHeight];
    }else if (topViewFrame.size.height > (self.topView.maxHeight + self.topView.minHeight)/2 && topViewFrame.size.height != self.topView.maxHeight) {
        [self animateTopViewTo:self.topView.maxHeight];
    }
}

- (void)animateTabBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        CGRect addPictureFrame =  self.addPicture.frame;
        frame.origin.y = y;
        addPictureFrame.origin.y = frame.origin.y - 18 - addPictureFrame.size.height;
        [self.tabBarController.tabBar setFrame:frame];
        [self.addPicture setFrame:addPictureFrame];
    }];
}

- (void)animateTopViewTo:(CGFloat)height
{
    [self.view removeConstraint:self.topViewHeightConstraint];
    self.topViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.topView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0
                                                                 constant:height];
    [self.view addConstraint:self.topViewHeightConstraint];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint contentOffset = self.collectionView.contentOffset;
        contentOffset.y = self.topView.maxHeight - height;
        [self.collectionView setContentOffset:contentOffset];
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - UITextView

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.selectedTextView = textView;
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 50)];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(keyboardDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    [keyboardToolbar sizeToFit];
    self.selectedTextView.inputAccessoryView = keyboardToolbar;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.person.note = textView.text;
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    CGRect textViewFrame = [textView.superview convertRect:textView.frame toView:self.view];
    CGFloat textViewBottom = textViewFrame.origin.y + textViewFrame.size.height;
    
    //if the bottom of the textview is hided by the keyboard
   if (textViewBottom > self.view.frame.size.height - keyboardHeight) {
        //update scroll offset
        CGPoint contentOffset = self.collectionView.contentOffset;
        CGFloat hiddenPortionHeight = textViewBottom - (self.view.frame.size.height - keyboardHeight);
        contentOffset.y = contentOffset.y + hiddenPortionHeight;
        [self.collectionView setContentOffset:contentOffset];
    }
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //save note to the memory
    [flmgr setNote:self.person.note forPersonIndex:[self.person.index integerValue]];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    //get the height of the keyboard when the keyboard show
    NSValue *keyboardFrame = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRectangle = [keyboardFrame CGRectValue];
    keyboardHeight = keyboardRectangle.size.height;
}

- (void)keyboardDoneButtonPressed
{
    [self.selectedTextView resignFirstResponder];
}

#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a PictureViewController
    if (fromVC == self && [toVC isKindOfClass:[PictureViewController class]]) {
        return [[ImageOpeningPresenter alloc] init];
    }
    else {
        return nil;
    }
}
@end
