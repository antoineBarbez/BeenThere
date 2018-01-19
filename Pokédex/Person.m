//
//  Person.m
//  Pokédex
//
//  Created by Antoine Barbez on 14/12/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "Person.h"

@implementation Person

-(id) initWithDictionary:(NSDictionary *) dictionary {
    if (self = [super init]) {
        if ([dictionary objectForKey:@"nom"])
            self.lastname = [dictionary objectForKey:@"nom"];
        
        if ([dictionary objectForKey:@"prenom"])
            self.firstname = [dictionary objectForKey:@"prenom"];
        
        if ([dictionary objectForKey:@"countryIndex"]) {
            NSUInteger countryIndex = [[dictionary objectForKey:@"countryIndex"] longValue];
            self.country = [[Country alloc] initWithIndex:countryIndex];
        }
        
        self.medias = [dictionary objectForKey:@"medias"];
        self.index = [dictionary objectForKey:@"index"];
        self.note = [dictionary objectForKey:@"note"];
        
        
    }
    return self;
}
@end
