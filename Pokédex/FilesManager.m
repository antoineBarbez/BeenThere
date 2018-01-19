//
//  FilesManager.m
//  Pokédex
//
//  Created by Antoine Barbez on 27/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import "FilesManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation FilesManager

@synthesize dataDirPath;
@synthesize countriesPath;
@synthesize personsPath;


//Method that return the unique instance of "FilesManager" (Singleton design pattern)
+(FilesManager *)sharedFilesMgr {
    static FilesManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init {
    
    if ( self = [super init] ) {
        NSFileManager *filemgr;
        NSArray *dirPaths;
        NSString *docsDir;
        
        filemgr =[NSFileManager defaultManager];
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        
        [self setDataDirPath:docsDir];
        [self setCountriesPath:[docsDir stringByAppendingString:@"/Countries"]];
        [self setPersonsPath:[docsDir stringByAppendingString:@"/Persons"]];
        
        
        if([filemgr fileExistsAtPath:countriesPath]) {
            NSLog(@"countries exists");
        }else {
            NSLog(@"countries does not exists");
            [self createCountriesFile];
        }
        
        
        if([filemgr fileExistsAtPath:personsPath]) {
            NSLog(@"persons exists");
        }else {
            NSLog(@"persons does not exists");
            [self createPersonsFile];
        }
        
    }
         
    return self;
    
}




//Create the editable "Countries" file from the "Countries.plist" resources file
-(void) createCountriesFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    if ([data writeToFile:countriesPath atomically:NO]) {
        NSLog(@"Création de Countries réussie !");
    }else {
        //handle error
        NSLog(@"Échec lors de la création de Countries");
    }
    
}

//Create the editable "persons" file
-(void) createPersonsFile {
    NSArray *data = [[NSArray alloc] init];
    
    if ([data writeToFile:personsPath atomically:NO]) {
        NSLog(@"Création de Persons réussie !");
    }else {
        //handle error
        NSLog(@"Échec lors de la création de Persons");
    }
}


-(void) setNote:(NSString *)note forPersonIndex:(NSUInteger) personIndex {
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithDictionary:[persons objectAtIndex:personIndex]];
    
    [person setObject:note forKey:@"note"];
    
    [persons setObject:person atIndexedSubscript:personIndex];
    [persons writeToFile:personsPath atomically:NO];
}


-(void) addPicture:(NSData *) imageData forPersonIndex:(NSUInteger) personIndex {
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithDictionary:[persons objectAtIndex:personIndex]];
    NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[person objectForKey:@"medias"]];
    
    NSUInteger imageId;
    if (medias.count == 0) {
        imageId = medias.count;
    }else {
        NSArray *splitName = [[medias lastObject] componentsSeparatedByString:@"-"];
        NSUInteger lastImageId = [[splitName objectAtIndex:2] integerValue];
        imageId = lastImageId + 1;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"image-%lu-%lu",(unsigned long)personIndex, imageId];
    NSString *imagePath =[dataDirPath stringByAppendingPathComponent:imageName];
    
    if (![imageData writeToFile:imagePath atomically:NO]) {
        NSLog(@"Failed to cache image data to disk");
        
    }else {
        [medias addObject:imageName];
        [person setObject:medias forKey:@"medias"];
        [persons setObject:person atIndexedSubscript:personIndex];
        [persons writeToFile:personsPath atomically:NO];
        
        NSLog(@"the cachedImagedPath is %@",imagePath);
    }
}

-(void) addVideo:(NSURL *) videoURL forPersonIndex:(NSUInteger) personIndex {
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithDictionary:[persons objectAtIndex:personIndex]];
    NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[person objectForKey:@"medias"]];
    
    NSUInteger videoId;
    if (medias.count == 0) {
        videoId = 0;
    }else {
        NSArray *splitName = [[medias lastObject] componentsSeparatedByString:@"-"];
        NSUInteger lastVideoId = [[splitName objectAtIndex:2] integerValue];
        videoId = lastVideoId + 1;
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL: videoURL options:nil];
    
    //get the video duration
    CMTime duration = [asset duration];
    int secondsValue = ceil(duration.value/duration.timescale);
    int sec = secondsValue % 60;
    int min = (int)(secondsValue - sec)/60;
    NSString *durationString = [NSString stringWithFormat:@"%i:%i",min,sec];
    
    //define the different paths
    NSString *videoName = [NSString stringWithFormat:@"video-%lu-%lu-%@.mov", (unsigned long)personIndex, videoId, durationString];
    NSString *thumbnailName = [NSString stringWithFormat:@"thumbnail-%lu-%lu-%@", (unsigned long)personIndex, videoId, durationString];
    NSString *videoPath =[dataDirPath stringByAppendingPathComponent:videoName];
    NSString *thumbnailPath =[dataDirPath stringByAppendingPathComponent:thumbnailName];
    
    //get and save the datas at their paths
    UIImage *thumbnailImage = [self thumbnailFromAsset:asset];
    
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 1.0f);
    
    if (![videoData writeToFile:videoPath atomically:NO]) {
        NSLog(@"Failed to cache video data to disk");
        
    }else {
        if (![thumbnailData writeToFile:thumbnailPath atomically:NO]) {
            NSLog(@"Failed to cache thumbnail data to disk");
        }else {
            [medias addObject:videoName];
            [person setObject:medias forKey:@"medias"];
            [persons setObject:person atIndexedSubscript:personIndex];
            [persons writeToFile:personsPath atomically:NO];
            
            NSLog(@"the cachedVideoPath is %@",videoPath);
        }
    }
}

//return an the first image of the video as a thumbnail
- (UIImage *)thumbnailFromAsset:(AVAsset *)asset {
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES; // To make the thumbnail well oriented (portrait/landscape)
    NSError *err = NULL;
    CMTime requestedTime = CMTimeMake(1, 60);     // To create thumbnail image
    CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
    NSLog(@"err = %@, imageRef = %@", err, imgRef);
    
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);    // MUST release explicitly to avoid memory leak
    
    return thumbnailImage;
}

/*
-(NSArray *)getVideoSliderImagesWithUrl:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL: videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES; // To make the thumbnail well oriented (portrait/landscape)
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    CMTime duration = [asset duration];
    int secondsValue = ceil(duration.value/duration.timescale);
    
    if (secondsValue < 4) {
        NSError *err = NULL;
        CMTime requestedTime = CMTimeMake(1, 60);
        CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
        NSLog(@"err = %@, imageRef = %@", err, imgRef);
        
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
        CGImageRelease(imgRef);
        
        for (int i=0; i<10; i++) {
            [array addObject:thumbnailImage];
        }
    }else {
        CGFloat interval = (secondsValue-2)/10;
        for (int i=0; i<10; i++) {
            NSError *err = NULL;
            CMTime requestedTime = CMTimeMakeWithSeconds(1+i*interval, 60000);
            CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
            NSLog(@"err = %@, imageRef = %@", err, imgRef);
            
            UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
            CGImageRelease(imgRef);
            
            [array addObject:thumbnailImage];
        }
    }
    
    return array;
}*/


/*
-(NSArray <UIImage *> *) getImagesWithPicturesNames:(NSArray <NSString *> *) pictureNames {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    for (NSString *pictureName in pictureNames) {
        NSString *imageNameWithExtention = [pictureName stringByAppendingString:@".png"];
        NSString *imagePath =[dataDirPath stringByAppendingPathComponent:imageNameWithExtention];
        
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        [images addObject:image];
    }
    
    return images;
}*/

-(NSArray *) getMediasWithMediaNames:(NSArray <NSString *> *) mediaNames {
    NSMutableArray *medias = [[NSMutableArray alloc] init];
    
    for (NSString *mediaName in mediaNames) {
        NSArray *splitName = [mediaName componentsSeparatedByString:@"-"];
        NSString *mediaType = splitName.firstObject;
        
        NSDictionary *mediaDictionnary;
        if ([mediaType isEqualToString:@"image"]) {
            //the media is an image
            NSString *imagePath =[dataDirPath stringByAppendingPathComponent:mediaName];
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            NSArray *objects = [[NSArray alloc] initWithObjects:@"image", image, nil];
            NSArray *keys = [[NSArray alloc] initWithObjects:@"mediaType", @"image", nil];
            mediaDictionnary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        }else {
            //the media is a video
            
            //get the video's thumbnail name and the video duration
            NSUInteger personIndex = [[splitName objectAtIndex:1] integerValue];
            NSUInteger videoId = [[splitName objectAtIndex:2] integerValue];
            NSString *videoDuration = [[splitName objectAtIndex:3] componentsSeparatedByString:@"."].firstObject;
            NSString *thumbnailName = [NSString stringWithFormat:@"thumbnail-%lu-%lu-%@", (unsigned long)personIndex, videoId, videoDuration];
            
            
            NSString *videoPath =[dataDirPath stringByAppendingPathComponent:mediaName];
            NSString *thumbnailPath =[dataDirPath stringByAppendingPathComponent:thumbnailName];
            
            NSData *thumbnailData = [[NSData alloc] initWithContentsOfFile:thumbnailPath];
            UIImage *thumbnail = [[UIImage alloc] initWithData:thumbnailData];
            
            NSArray *objects = [[NSArray alloc] initWithObjects:@"video", thumbnail, videoPath, videoDuration,nil];
            NSArray *keys = [[NSArray alloc] initWithObjects:@"mediaType", @"image", @"videoPath", @"duration",nil];
            mediaDictionnary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            
        }
        
        [medias addObject:mediaDictionnary];
    }
    
    return medias;
}

/*
-(void) deletePictureWithPersonIndex:(NSUInteger) personIndex andImageIndex:(NSUInteger) imageIndex {
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithDictionary:[persons objectAtIndex:personIndex]];
    NSMutableArray *pictures = [[NSMutableArray alloc] initWithArray:[person objectForKey:@"pictures"]];
    
    NSString *imageName = [pictures objectAtIndex:imageIndex];
    NSString *imageNameWithExtention = [imageName stringByAppendingString:@".png"];
    NSString *imagePath =[dataDirPath stringByAppendingPathComponent:imageNameWithExtention];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:imagePath error:&error];
    if (success) {
        
        [pictures removeObjectAtIndex:imageIndex];
        [person setObject:pictures forKey:@"pictures"];
        [persons setObject:person atIndexedSubscript:personIndex];
        [persons writeToFile:personsPath atomically:NO];
        
        NSLog(@"Picture successfully removed");
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
}*/


-(void) deleteMediaWithPersonIndex:(NSUInteger) personIndex andMediaIndex:(NSUInteger) mediaIndex {
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    NSMutableDictionary *person = [[NSMutableDictionary alloc] initWithDictionary:[persons objectAtIndex:personIndex]];
    NSMutableArray *medias = [[NSMutableArray alloc] initWithArray:[person objectForKey:@"medias"]];
    
    NSString *mediaName = [medias objectAtIndex:mediaIndex];
    NSArray *splitName = [mediaName componentsSeparatedByString:@"-"];
    NSString *mediaType = splitName.firstObject;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success;
    if ([mediaType isEqualToString:@"image"]) {
        NSString *imagePath =[dataDirPath stringByAppendingPathComponent:mediaName];
        success = [fileManager removeItemAtPath:imagePath error:&error];
    }else {
        NSUInteger personIndex = [[splitName objectAtIndex:1] integerValue];
        NSUInteger videoId = [[splitName objectAtIndex:2] integerValue];
        NSString *videoDuration = [[splitName objectAtIndex:3] componentsSeparatedByString:@"."].firstObject;
        NSString *thumbnailName = [NSString stringWithFormat:@"thumbnail-%lu-%lu-%@", (unsigned long)personIndex, videoId, videoDuration];
        
        
        NSString *videoPath =[dataDirPath stringByAppendingPathComponent:mediaName];
        NSString *thumbnailPath =[dataDirPath stringByAppendingPathComponent:thumbnailName];
        
        BOOL deleteVideo = [fileManager removeItemAtPath:videoPath error:&error];
        BOOL deleteThumbnail = [fileManager removeItemAtPath:thumbnailPath error:&error];
        
        success = deleteVideo && deleteThumbnail;
    }
    
    if (success) {
        
        [medias removeObjectAtIndex:mediaIndex];
        [person setObject:medias forKey:@"medias"];
        [persons setObject:person atIndexedSubscript:personIndex];
        [persons writeToFile:personsPath atomically:NO];
        
        NSLog(@"media successfully removed");
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
}


-(NSDictionary *) getCountryForIndex:(NSUInteger) index {
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:countriesPath];
    NSDictionary *country = [data objectAtIndex:index];
    
    return country;
}

-(NSArray *) getVisitedCountries {
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:countriesPath];
    NSMutableArray *visitedCountries = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<data.count;i++) {
        NSDictionary *country = [data objectAtIndex:i];
        NSArray *persons = [country objectForKey:@"persons"];
        if (persons.count > 0) {
            NSNumber *index = [[NSNumber alloc] initWithInt:i];
            [visitedCountries addObject:index];
        }
    }
    return visitedCountries;
}

-(void) addPersonToCountryWithPersonIndex:(NSNumber *) personIndex forCountryIndex:(NSUInteger) countryIndex {
    NSMutableArray *countries = [[NSMutableArray alloc] initWithContentsOfFile:countriesPath];
    NSMutableDictionary *country = [countries objectAtIndex:countryIndex];
    NSMutableArray *persons = [country objectForKey:@"persons"];
    
    [persons addObject:personIndex];
    [country setObject:persons forKey:@"persons"];
    [countries setObject:country atIndexedSubscript:countryIndex];
    
    [countries writeToFile:countriesPath atomically:NO];
}

-(void) deletePersonToCountryWithPersonIndex:(NSNumber *) personIndex forCountryIndex:(NSUInteger) countryIndex {
    NSMutableArray *countries = [[NSMutableArray alloc] initWithContentsOfFile:countriesPath];
    NSMutableDictionary *country = [countries objectAtIndex:countryIndex];
    NSMutableArray *persons = [country objectForKey:@"persons"];
    
    for (NSUInteger i=0; i<persons.count; i++) {
        if ([[persons objectAtIndex:i] isEqualToNumber:personIndex]) {
            NSLog(@"%lu",(unsigned long)i);
            [persons removeObjectAtIndex:i];
        }
    }
    
    [country setObject:persons forKey:@"persons"];
    [countries setObject:country atIndexedSubscript:countryIndex];
    
    [countries writeToFile:countriesPath atomically:NO];
}

-(NSUInteger) countCountries {
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:countriesPath];
    long nb = data.count;
    
    return nb;
}



-(NSDictionary *) getPersonForIndex:(NSUInteger) index {
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:personsPath];
    NSDictionary *person = [data objectAtIndex:index];
    
    return person;
}

-(NSArray *) getPersons {
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:personsPath];
    
    return data;
}

-(void) addPersonWithDictionary:(NSDictionary *) dict {
    //add the new person to it's country
    NSNumber *index = [[NSNumber alloc] initWithLong:[self countPersons]];
    [self addPersonToCountryWithPersonIndex:index
                            forCountryIndex:[[dict objectForKey:@"countryIndex"] unsignedIntegerValue]];
    
    //add the new person to the resource file
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    [persons addObject:dict];
    
    [persons writeToFile:personsPath atomically:NO];
}

-(void) deletePersonWithIndex:(NSNumber *) personIndex {
    NSUInteger index = [personIndex unsignedIntegerValue];
    NSDictionary *person = [self getPersonForIndex:index];
     //remove the person to it's country
    NSUInteger countryIndex = [[person objectForKey:@"countryIndex"] unsignedIntegerValue];
    
    [self deletePersonToCountryWithPersonIndex:personIndex forCountryIndex:countryIndex];
    
    //delete the person's medias
    NSArray *medias = [person objectForKey:@"medias"];
    for (NSUInteger i=0; i<medias.count; i++) {
        [self deleteMediaWithPersonIndex:index andMediaIndex:i];
    }
    
    //Update the persons indexes in all visited countries
    NSArray *visitedCountries = [self getVisitedCountries];
    NSMutableArray *countries = [[NSMutableArray alloc] initWithContentsOfFile:countriesPath];
    
    for (NSNumber *visitedCountryIndex in visitedCountries) {
        NSMutableDictionary *visitedCountry = [countries objectAtIndex:[visitedCountryIndex unsignedIntegerValue]];
        NSMutableArray *personsInVisitedCountry = [visitedCountry objectForKey:@"persons"];
        
        for (int i=0; i<personsInVisitedCountry.count; i++) {
            if ([personsInVisitedCountry objectAtIndex:i] > personIndex) {
                int newIndex = [[personsInVisitedCountry objectAtIndex:i] intValue] - 1;
                [personsInVisitedCountry setObject:[NSNumber numberWithInt:newIndex] atIndexedSubscript:i];
            }
        }
        
        [visitedCountry setObject:personsInVisitedCountry forKey:@"persons"];
        [countries setObject:visitedCountry atIndexedSubscript:[visitedCountryIndex unsignedIntegerValue]];
    }
    
    [countries writeToFile:countriesPath atomically:NO];
    
    
    
    //remove the person to the resource file
    NSMutableArray *persons = [[NSMutableArray alloc] initWithContentsOfFile:personsPath];
    [persons removeObjectAtIndex:index];
    
    [persons writeToFile:personsPath atomically:NO];
}

-(NSUInteger) countPersons {
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:personsPath];
    long nb = data.count;
    
    return nb;
}




@end
