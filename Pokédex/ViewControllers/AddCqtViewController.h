//
//  AddCqtViewController.h
//  Pokédex
//
//  Created by Antoine Barbez on 08/10/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListeViewController.h"
#import "MyTextField.h"
#import "MLPAutoCompleteTextField.h"
#import "MLPAutoCompleteTextFieldDelegate.h"
#import "CountryDataSource.h"
#import "FilesManager.h"

@interface AddCqtViewController : UIViewController <UITextFieldDelegate,MLPAutoCompleteTextFieldDelegate> {
    NSNumber *personIndex;
    NSNumber *selectedCountryIndex;
    BOOL aCountryIsSelected;
    
}


@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) IBOutlet UITextField *prenom_textField;
@property (strong, nonatomic) IBOutlet UITextField *nom_textField;
@property (strong, nonatomic) IBOutlet MLPAutoCompleteTextField *country_textField;
@property (strong, nonatomic) CountryDataSource *dataSource;
@property (strong, nonatomic) FilesManager *flmgr;


@property (strong, nonatomic) ListeViewController *listeViewController;


- (void) addNewPerson;
- (IBAction)cancelButton:(id)sender;
- (IBAction)addButton:(id)sender;

@end
