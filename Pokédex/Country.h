//
//  Country.h
//  Pokédex
//
//  Created by Antoine Barbez on 15/12/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MLPAutoCompletionObject.h"
#import "FilesManager.h"
#import "PocketSVG.h"


@interface Country : NSObject <MLPAutoCompletionObject> {
    NSUInteger index;
}

@property (strong, nonatomic) FilesManager *flmgr;

@property (strong, nonatomic) NSString *frenchName;
@property (strong, nonatomic) NSString *englishName;
@property (strong, nonatomic) NSArray *persons;
@property (strong, nonatomic) NSArray *position;


-(NSUInteger) getIndex;
-(void) setIndex:(NSUInteger) idx;

- (id) initWithIndex:(NSUInteger)index;
- (UIImage *)getFlag;
- (UIImage *)getImage;
@end
