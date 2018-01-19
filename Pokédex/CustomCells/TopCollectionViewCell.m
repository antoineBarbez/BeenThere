//
//  TopCollectionViewCell.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 12/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "TopCollectionViewCell.h"

@implementation TopCollectionViewCell
/*
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TopCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        NSLog(@"yyyyyy");
    }
    
    return self;
}*/

+ (TopCollectionViewCell *) fromNib {
    TopCollectionViewCell *cell;
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TopCollectionViewCell" owner:nil options:nil];
    
    if ([arrayOfViews count] < 1) {
        return nil;
    }
    
    for (UIView *nibView in arrayOfViews) {
        if ([nibView isKindOfClass:[TopCollectionViewCell class]]) {
            cell = (TopCollectionViewCell*)nibView;
        }
    }
    return cell;
}

@end
