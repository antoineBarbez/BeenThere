//
//  CountryDataSource.h
//  Pokédex
//
//  Created by Antoine Barbez on 15/12/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompleteTextFieldDataSource.h"
#import "FilesManager.h"

@interface CountryDataSource : NSObject <MLPAutoCompleteTextFieldDataSource>
    @property (strong, nonatomic) FilesManager *flmgr;
@end
