//
//  Person.h
//  Pokédex
//
//  Created by Antoine Barbez on 14/12/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Country.h"

@interface Person : NSObject

@property (strong, nonatomic) NSString *lastname;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *note;
@property (strong, nonatomic) NSArray<NSString *> *medias;
@property (strong, nonatomic) Country *country;
@property (strong, nonatomic) NSNumber *index;


-(id) initWithDictionary:(NSDictionary *) dictionary;
@end
