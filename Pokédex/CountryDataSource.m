//
//  CountryDataSource.m
//  Pokédex
//
//  Created by Antoine Barbez on 15/12/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "CountryDataSource.h"
#import "Country.h"

@implementation CountryDataSource

@synthesize flmgr;


-(id)init{
    self = [super init];
    if(self) {
        flmgr = [FilesManager sharedFilesMgr];
    }
    return self;
}


#pragma mark - MLPAutoCompleteTextField DataSource

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    
    NSArray *completions;
    completions = [self allCountryObjects];
    
    handler(completions);
}



//Return an array of all the country objects
- (NSArray *)allCountryObjects
{
    
    NSMutableArray *mutableCountries = [NSMutableArray new];
    
    for (int i = 0; i<[flmgr countCountries]; i++){
        Country *country = [[Country alloc] initWithIndex:i];
        [mutableCountries addObject:country];
    }
    
    NSArray *countryObjects = [NSArray arrayWithArray:mutableCountries];
    
    return countryObjects;
}


@end
