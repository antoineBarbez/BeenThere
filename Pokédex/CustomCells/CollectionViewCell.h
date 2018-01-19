//
//  CollectionViewCell.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 01/08/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
