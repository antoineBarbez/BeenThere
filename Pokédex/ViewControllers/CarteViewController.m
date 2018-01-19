//
//  SecondViewController.m
//  Pokédex
//
//  Created by Antoine Barbez on 26/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "CarteViewController.h"

@interface CarteViewController ()

@end

@implementation CarteViewController

@synthesize flmgr;
@synthesize tapGestureRecogniser;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    flmgr = [FilesManager sharedFilesMgr];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map.png"]];
    self.imageView.frame = CGRectMake(0, 0, [UIImage imageNamed:@"map.png"].size.width, [UIImage imageNamed:@"map.png"].size.height);
    
    [self.scrollView addSubview:self.imageView];
    self.scrollView.delegate = self;
    
    
    tapGestureRecogniser = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(handleTap:)];
    [self.imageView addGestureRecognizer:tapGestureRecogniser];
    self.imageView.userInteractionEnabled = TRUE;
    
}

-(void) initContentDisplay {
    self.scrollView.maximumZoomScale = 1;
    [self updateMinZoomScaleForSize:self.scrollView.bounds.size];
    [self updateConstraintsForSize:self.scrollView.bounds.size];
    CGFloat initialZoomScale = self.scrollView.bounds.size.height/self.imageView.bounds.size.height;
    self.scrollView.zoomScale = initialZoomScale;
    
    [self updateOffset];
    
}

-(void) updateMinZoomScaleForSize:(CGSize) size {
    CGFloat widthScale = size.width/self.imageView.bounds.size.width;
    CGFloat heightScale = size.height/self.imageView.bounds.size.height;
    
    CGFloat minScale = MIN(widthScale, heightScale);
    self.scrollView.minimumZoomScale = minScale;
}

-(void) updateConstraintsForSize:(CGSize) size {
    CGFloat xOffset = MAX(0, (size.width - self.imageView.frame.size.width)/2);
    CGFloat yOffset = MAX(0, (size.height - self.imageView.frame.size.height)/2);
    self.imageView.frame = CGRectMake(xOffset, yOffset, self.imageView.frame.size.width, self.imageView.frame.size.height);
}

-(void) updateOffset {
    CGFloat xOffset = self.scrollView.contentOffset.x;
    CGFloat yOffset = self.scrollView.contentOffset.y;
    
    if (self.imageView.frame.size.width > self.scrollView.frame.size.width) {
        xOffset = MAX(0, (self.imageView.frame.size.width - self.scrollView.bounds.size.width)/2);
    }
    
    if (self.imageView.frame.size.height > self.scrollView.frame.size.height) {
        yOffset = MAX(0, (self.imageView.frame.size.height - self.scrollView.bounds.size.height)/2);
    }
    
    self.scrollView.contentOffset = CGPointMake(xOffset, yOffset);
}


-(void) reloadMapSubviews {
    [self.imageView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    NSArray *visitedCountries = [flmgr getVisitedCountries];
    for (NSNumber * index in visitedCountries) {
        CountryView *country = [[CountryView alloc] initWithIndex:index.floatValue];
        
        if (country != nil)
            [self.imageView addSubview:country];
    }
}

- (void) handleTap:(UITapGestureRecognizer *) sender {
    CGPoint location = [sender locationInView:sender.view];
    NSArray *touchedSubviews = [self touchedSubviews:location];
    
    Country *selectedCountry = nil;
    if (touchedSubviews.count > 0) {
        for (CountryView *subview in touchedSubviews) {
            CGPoint locationInSubview = CGPointMake(location.x-subview.frame.origin.x, location.y-subview.frame.origin.y);
            if([subview isPointInsideCountry:locationInSubview]){
                selectedCountry = subview.country;
            }
        }
    }
    
    if (selectedCountry != nil) {
        //handle the click on a country
        NSLog(@"%@", selectedCountry.frenchName);
        for (NSNumber *personIndex in selectedCountry.persons) {
            NSLog(@"%@",personIndex);
        }
    }
}

//Return an array containing all the subviews of imageView that contains a point
- (NSArray *) touchedSubviews:(CGPoint) point {
    NSMutableArray *touchedSubviews = [[NSMutableArray alloc] init];
    
    for (UIView *subview in self.imageView.subviews) {
        if ([self isPoint:point InsideSubview:subview]) {
            [touchedSubviews addObject:subview];
        }
    }
    return touchedSubviews;
}

//return YES if the point is inside the subview
- (BOOL) isPoint:(CGPoint)point InsideSubview:(UIView *)subview {
    
    if (point.x<subview.frame.origin.x || point.x > subview.frame.origin.x + subview.frame.size.width ) {
        return NO;
    }
    
    if (point.y<subview.frame.origin.y || point.y > subview.frame.origin.y + subview.frame.size.height) {
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    if (self.isViewLoaded && self.view.window) {
        if (self.view.bounds.size.width < size.width) {
            NSLog(@"from portrait to landscape");
            self.tabBarController.tabBar.hidden = YES;
        }else {
            NSLog(@"from landscape to portrait");
            self.tabBarController.tabBar.hidden = NO;
        }
    }
}


-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateMinZoomScaleForSize:self.scrollView.bounds.size];
    if (self.scrollView.zoomScale < self.scrollView.minimumZoomScale) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
    [self updateConstraintsForSize:self.scrollView.bounds.size];
    [self updateOffset];
    [self.scrollView setContentSize:self.imageView.frame.size];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadMapSubviews];
    [self initContentDisplay];
}

#pragma mark - UIScrollView Delagate

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateConstraintsForSize:self.scrollView.bounds.size];
}


@end
