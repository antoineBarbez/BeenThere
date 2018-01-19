//
//  SecondViewController.h
//  Pokédex
//
//  Created by Antoine Barbez on 26/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilesManager.h"
#import "CountryView.h"
#import "Country.h"

@interface CarteViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) FilesManager *flmgr;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecogniser;

@end

