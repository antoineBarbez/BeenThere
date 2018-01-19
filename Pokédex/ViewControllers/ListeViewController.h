//
//  FirstViewController.h
//  Pokédex
//
//  Created by Antoine Barbez on 26/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilesManager.h"


@interface ListeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}
@property (strong,nonatomic) FilesManager *flmgr;
@property (strong, nonatomic) IBOutlet UITableView *table_view;


//- (IBAction)buttonNewCqt:(id)sender;

@end

