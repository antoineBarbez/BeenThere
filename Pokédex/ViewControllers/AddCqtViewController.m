//
//  AddCqtViewController.m
//  Pokédex
//
//  Created by Antoine Barbez on 08/10/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "AddCqtViewController.h"
#import "Country.h"

@interface AddCqtViewController ()

@end

@implementation AddCqtViewController

@synthesize prenom_textField;
@synthesize nom_textField;
@synthesize country_textField;
@synthesize addButton;
@synthesize flmgr;

@synthesize listeViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    flmgr = [FilesManager sharedFilesMgr];
    
    personIndex = [NSNumber numberWithInteger:[flmgr countPersons]];
    aCountryIsSelected = NO;
    
    [addButton setEnabled:NO];
    [addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    prenom_textField.delegate = self;
    [prenom_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [prenom_textField becomeFirstResponder];
    
    nom_textField.delegate = self;
    [nom_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.dataSource = [[CountryDataSource alloc] init];
    country_textField.autoCompleteDataSource = self.dataSource;
    country_textField.autoCompleteDelegate = self;
    country_textField.delegate = self;
    [country_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)textFieldDidChange :(UITextField *)theTextField{
    if (theTextField == country_textField) {
        aCountryIsSelected = NO;
    }
    
    [self updateAddButtonState];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"3");
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButton:(id)sender {
    [self addNewPerson];
    
    [listeViewController.table_view reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) updateAddButtonState {
    if ((prenom_textField.hasText || nom_textField.hasText) && aCountryIsSelected) {
        [addButton setEnabled:YES];
    }else {
        [addButton setEnabled:NO];
    }
}

- (void) addNewPerson {
    NSArray *medias = [[NSArray alloc] init];
    NSArray *data = [[NSArray alloc] initWithObjects:personIndex, prenom_textField.text, nom_textField.text, selectedCountryIndex, medias, @"", nil];
    NSArray *structure = @[@"index", @"prenom", @"nom", @"countryIndex", @"medias", @"note"];
    NSDictionary *person;
    person = [[NSDictionary alloc] initWithObjects:data forKeys:structure];
    
    [flmgr addPersonWithDictionary:person];
}



#pragma mark - MLPAutoCompleteTextField Delegate

- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(Country *)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    
    [cell.imageView setImage:[autocompleteObject getFlag]];
    
    return YES;
}


- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(Country *)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCountryIndex = [[NSNumber alloc] initWithLong:[selectedObject getIndex]];
    aCountryIsSelected = YES;
    
    [self updateAddButtonState];
}
@end
