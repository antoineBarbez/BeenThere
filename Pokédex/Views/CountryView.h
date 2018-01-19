//
//  CountryView.h
//  map
//
//  Created by Antoine Barbez on 09/01/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilesManager.h"
#import "Country.h"

@interface CountryView : UIImageView

@property (strong, nonatomic) FilesManager *flmgr;
@property (strong, nonatomic) Country *country;

- (id) initWithIndex:(NSUInteger)index;
- (BOOL)isPointInsideCountry:(CGPoint)point;
@end
