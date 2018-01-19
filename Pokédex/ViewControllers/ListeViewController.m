//
//  FirstViewController.m
//  Pokédex
//
//  Created by Antoine Barbez on 26/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "ListeViewController.h"
#import "CqtTableViewCell.h"
#import "CqtDetailViewController.h"
#import "AddCqtViewController.h"
#import "Person.h"

@interface ListeViewController ()

@end

@implementation ListeViewController

@synthesize flmgr;
@synthesize table_view;

- (void)viewDidLoad {
    [super viewDidLoad];
    flmgr = [FilesManager sharedFilesMgr];
    
}

/*
- (IBAction)buttonNewCqt:(id)sender {
    
    [self.table_view reloadData];
    
}*/


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowCqtDetails"])
    {
        CqtDetailViewController *detailViewController =
        [segue destinationViewController];
        
        NSIndexPath *myIndexPath = [self.table_view
                                    indexPathForSelectedRow];
        
        long row = [flmgr countPersons] - [myIndexPath row] -1;
        NSDictionary *person = [flmgr getPersonForIndex:row];
        
        detailViewController.person = [[Person alloc] initWithDictionary:person];
        detailViewController.listeViewController = self;
        
    }else if ([[segue identifier] isEqualToString:@"AddNewCqt"]) {
        
        AddCqtViewController *addCqtViewController = [segue destinationViewController];
        
        addCqtViewController.listeViewController = self;
        
    }
}






#pragma mark - UITableView DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [flmgr countPersons];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CqtTableCell";
    CqtTableViewCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifier
                              forIndexPath:indexPath];
    
    // Configure the cell...
    
    long row = [flmgr countPersons] - [indexPath row] -1;
    long num = row +1;
    
    NSDictionary *person = [flmgr getPersonForIndex:row];
    cell.prenom.text = [person objectForKey:@"prenom"];
    cell.nom.text = [person objectForKey:@"nom"];
    cell.numero.text = [NSString stringWithFormat:@"%ld",num];
    
    return cell;
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
