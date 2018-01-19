//
//  CountryView.m
//  map
//
//  Created by Antoine Barbez on 09/01/2017.
//  Copyright © 2017 Antoine Barbez. All rights reserved.
//

#import "CountryView.h"

@implementation CountryView

@synthesize flmgr;
@synthesize country;


- (id) initWithIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        if([self setup:index]) {
            return self;
        }
    }
    return nil;
}

- (BOOL)setup:(NSUInteger)index
{
    flmgr = [FilesManager sharedFilesMgr];
    country = [[Country alloc] initWithIndex:index];
    
    if ([country getImage] == nil) {
        NSLog(@"no");
        return false;
    }else {
        NSLog(@"yes");
        NSNumber *xIn = [country.position objectAtIndex:0];
        NSNumber *yIn = [country.position objectAtIndex:1];
        float xPx = xIn.floatValue*326;
        float yPx = yIn.floatValue*326;
    
        [self setFrame:CGRectMake(xPx, yPx, [country getImage].size.width, [country getImage].size.height)];
        [self setImage:[country getImage]];
        
        return true;
    }
}

/*
- (void) handleTap:(UITapGestureRecognizer *) sender {
    CGPoint location = [sender locationInView:sender.view];
    if ([self isAlphaAtPoint:location forImage:self.image]) {
        NSLog(@"dedans");
    }else {
        NSLog(@"dehors");
    }
}*/

- (BOOL)isPointInsideCountry:(CGPoint)point {
    if ([self isAlphaAtPoint:point forImage:self.image]) {
        return YES;
    }else {
        return NO;
    }
}

/*
//Return yes if the Alpha is non null at the corresponding point
- (BOOL)isAlphaAtPoint:(CGPoint)point forImage:(UIImage *)image {
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((image.size.width  * (int)point.y) + (int)point.x ) * 4; // The image is png
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    
    if (alpha) return YES;
    else return NO;
    
}
*/

- (BOOL)isAlphaAtPoint:(CGPoint)point forImage:(UIImage *)image {
    
    int x = (int)point.x;
    int y = (int)point.y;
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    
    int alpha = (int)rawData[byteIndex + 3];
    
    free(rawData);
    
    if (alpha !=0) {
        return YES;
    }
    
    return NO;

}

@end
