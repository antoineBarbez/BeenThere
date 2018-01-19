//
//  MyTextField.m
//  Pokédex
//
//  Created by Antoine Barbez on 09/10/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField


-(id)initWithDefaultText:(NSString *) text {
    if (self = [super init]) {
        self.defaultText = text;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
