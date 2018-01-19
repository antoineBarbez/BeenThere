//
//  CqtDetailViewController.h
//  Pokédex
//
//  Created by Antoine Barbez on 08/10/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Person.h"
#import "ListeViewController.h"
#import "DetailTopView.h"

@interface CqtDetailViewController : UIViewController <UINavigationControllerDelegate,
                                                        UIImagePickerControllerDelegate,
                                                        UICollectionViewDataSource,
                                                        UICollectionViewDelegate,
                                                        UICollectionViewDelegateFlowLayout,
                                                        UITextViewDelegate
>
{
    FilesManager *flmgr;
    
}

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) ListeViewController *listeViewController;
@property (strong, nonatomic) NSArray *medias;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet DetailTopView *topView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UITextView *selectedTextView;
//@property (strong, nonatomic) IBOutlet UILabel *prenom;
//@property (strong, nonatomic) IBOutlet UILabel *nom;
//@property (strong, nonatomic) IBOutlet UILabel *country;
//@property (strong, nonatomic) IBOutlet UIImageView *flag;
@property (strong, nonatomic) IBOutlet UIButton *addPicture;

- (void)reloadDataWithPersonIndex:(NSInteger)personIndex;
- (void) resetCollectionViewLayout;

//- (IBAction)delete:(id)sender;
- (IBAction)addPicture:(id)sender;

@end
