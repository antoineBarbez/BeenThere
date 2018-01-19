//
//  TopCollectionViewCell.h
//  Pokédex_svg
//
//  Created by Antoine Barbez on 12/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextView.h"

@interface TopCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet  JVFloatLabeledTextView *textView;

+ (TopCollectionViewCell *) fromNib;
@end
