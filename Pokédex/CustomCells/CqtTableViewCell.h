//
//  CqtTableViewCell.h
//  Pokédex
//
//  Created by Antoine Barbez on 26/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CqtTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *prenom;

@property (strong, nonatomic) IBOutlet UILabel *nom;

@property (strong, nonatomic) IBOutlet UILabel *numero;
@end
