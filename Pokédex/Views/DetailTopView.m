//
//  DetailTopView.m
//  Pokédex_svg
//
//  Created by Antoine Barbez on 07/09/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "DetailTopView.h"

#define TOPVIEW_MAX_HEIGHT 280
#define TOPVIEW_MIN_HEIGHT 140
#define LABEL_BOTTOM_DISTANCE 90
#define CIRCLEIMAGE_BOTTOM_DISTANCE 128



@implementation DetailTopView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *className = NSStringFromClass([self class]);
        self.view = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        [self addSubview:self.view];
        self.maxHeight = self.frame.size.height;
        self.minHeight = 90 + 20 + 59;
        
        [self setFrame:self.view.frame];
        return self;
    }
    return nil;
}


-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.view setFrame:frame];
    
    CGFloat ratio = 1 - (self.maxHeight - frame.size.height)/(2*(self.maxHeight - self.minHeight));
    CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, ratio, ratio);
    CGAffineTransform translate = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, frame.size.height - self.maxHeight + (1-ratio)*self.flexibleView.frame.size.height);
    self.flexibleView.transform = CGAffineTransformConcat(scale, translate);
    
    self.counter.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, frame.size.height - self.maxHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
