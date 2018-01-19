//
//  Country.m
//  Pokédex
//
//  Created by Antoine Barbez on 15/12/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "Country.h"

@implementation Country

@synthesize flmgr;
@synthesize frenchName;
@synthesize englishName;
@synthesize persons;
@synthesize position;

- (id) initWithIndex:(NSUInteger)idx {
    self = [super init];
    if (self) {
        flmgr = [FilesManager sharedFilesMgr];
        NSDictionary *country = [flmgr getCountryForIndex:idx];
        
        [self setIndex:idx];
        [self setFrenchName:[country objectForKey:@"fr"]];
        [self setEnglishName:[country objectForKey:@"en"]];
        [self setPersons:[country objectForKey:@"persons"]];
        [self setPosition:[country objectForKey:@"position"]];
    }
    return self;
}



-(NSUInteger) getIndex {
    return index;
}


-(void) setIndex:(NSUInteger) idx {
    index = idx;
}

- (UIImage *)getFlag {
    NSString *flagName = [englishName stringByAppendingString:@".png"];
    UIImage *flag = [UIImage imageNamed:flagName];
    return flag;
}

- (UIImage *)getImage {
    if ([[position objectAtIndex:0] isEqualToString:@"0"]) {
        return nil;
    }
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:englishName withExtension:@"svg"];
    
    SVGBezierPath *path = [[SVGBezierPath pathsFromSVGAtURL:url] objectAtIndex:0];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    
    
    //Define the saturation of the country color
    CGFloat saturation = 0.5 + MIN(0.5, (CGFloat)persons.count/40);
    
    // Set its display properties
    layer.lineWidth   = 1;
    layer.strokeColor = [[UIColor whiteColor] CGColor];
    layer.fillColor   = [[UIColor colorWithHue:0 saturation:saturation brightness:1 alpha:1] CGColor];
    layer.backgroundColor = [[UIColor colorWithWhite:1 alpha:0] CGColor];
    //layer.frame = SVGBoundingRectForPaths([SVGBezierPath pathsFromSVGAtURL:url]);
    layer.frame = path.bounds;
    
    UIImage *image = [self imageFromLayer:layer];
    return image;
}



- (UIImage *)imageFromLayer:(CALayer *)layer {
    NSUInteger width = layer.frame.size.width;
    NSUInteger height = layer.frame.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    
    CGContextTranslateCTM( context, 0.5f * width, 0.5f * height ) ;
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM( context, -0.5f * width, -0.5f * height ) ;
    

    
    [layer renderInContext:context];
    CGImageRef graphicOutputImage = CGBitmapContextCreateImage(context);
    UIImage *outputImage = [UIImage imageWithCGImage:graphicOutputImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return outputImage;
    
    
}

#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString
{
    return frenchName;
}

@end
