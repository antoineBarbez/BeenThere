//
//  FilesManager.h
//  Pokédex
//
//  Created by Antoine Barbez on 27/09/2016.
//  Copyright © 2016 Antoine Barbez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FilesManager : NSObject {
   
}

@property (strong, nonatomic) NSString *dataDirPath;
@property (strong, nonatomic) NSString *countriesPath;
@property (strong, nonatomic) NSString *personsPath;


+(FilesManager *)sharedFilesMgr;

-(id)init;

-(void) createCountriesFile;
-(void) createPersonsFile;

-(NSDictionary *) getCountryForIndex:(NSUInteger) index;
-(NSArray *) getVisitedCountries;
-(NSUInteger) countCountries;
-(void) setNote:(NSString *)note forPersonIndex:(NSUInteger) personIndex;
-(void) addPicture:(NSData *) imageData forPersonIndex:(NSUInteger) personIndex;
-(void) addVideo:(NSURL *) videoURL forPersonIndex:(NSUInteger) personIndex;
//-(NSArray <UIImage *> *) getImagesWithPicturesNames:(NSArray <NSString *> *) pictureNames;
-(NSArray *) getMediasWithMediaNames:(NSArray <NSString *> *) mediaNames;
//-(void) deletePictureWithPersonIndex:(NSUInteger) personIndex andImageIndex:(NSUInteger) imageIndex;
//-(NSArray *)getVideoSliderImagesWithUrl:(NSURL *)videoURL;
-(void) deleteMediaWithPersonIndex:(NSUInteger) personIndex andMediaIndex:(NSUInteger) mediaIndex;
-(NSDictionary *) getPersonForIndex:(NSUInteger) index;
-(NSArray *) getPersons;
-(void) addPersonWithDictionary:(NSDictionary *) dict;
-(void) deletePersonWithIndex:(NSNumber *) personIndex;
-(NSUInteger) countPersons;

@end
