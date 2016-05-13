//
//  FlickretchTests.m
//  FlickretchTests
//
//  Created by Miguel Oliveira on 05/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Specta/Specta.h>
#import "Expecta.h"

#import "MGImageCache.h"
#import "MGFlickrAPI.h"
#import "MGFlickrService.h"

#import "MGFlickrUser.h"

#define EXP_SHORTHAND

SpecBegin(FlickretchTests)

describe(@"FlickretchTests", ^{
    
    it(@"should test the image cache class", ^{
        
        MGImageCache *imageCache = [[MGImageCache alloc] init];
        
        UIImage *appLogo = [UIImage imageNamed:@"Logo"];
        expect(appLogo).notTo.beNil;
        
        // getting the directory and the current number of files there
        
        NSArray *directories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                      inDomains:NSUserDomainMask];
        NSURL *directory = [directories firstObject];
        
        NSInteger numberFilesBefore = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory
                                                              includingPropertiesForKeys:nil
                                                                                 options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                                   error:nil] count];
        
        [imageCache cacheImage:appLogo forKey:@"cachedAppLogo"];
        
        NSInteger numberFilesAfter = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory
                                                                    includingPropertiesForKeys:nil
                                                                                       options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                                         error:nil] count];
        
        expect(numberFilesBefore).to.beLessThan(numberFilesAfter);
        
        UIImage *nonExistingImage = [imageCache cachedImageForKey:@"unicorn"];
        expect(nonExistingImage).to.beNil;
        
        UIImage *cachedImage = [imageCache cachedImageForKey:@"cachedAppLogo"];
        expect(cachedImage).notTo.beNil;
        
        expect(cachedImage.size.height).to.equal(appLogo.size.height);
        expect(cachedImage.size.width).to.equal(appLogo.size.width);
        
        [imageCache deleteImageForKey:@"cachedAppLogo"];
    });
    
    it(@"should test the flickr api class", ^{
        
        // test find by username URL
        
        NSURL *usernameURL = [MGFlickrAPI findByUsernameURLForUsername:@"boaty.mcboatface"];
        NSURL *expectedURL = [NSURL URLWithString:@"https://api.flickr.com/services/rest?nojsoncallback=1&method=flickr.people.findByUsername&api_key=efce8c297a3e440e2c3e38d366abd3a5&format=json&username=boaty.mcboatface"];
        
        expect(usernameURL).to.equal(expectedURL);
        
        // test find by email URL
        
        NSURL *emailURL = [MGFlickrAPI findByEmailURLForEmail:@"theone@matrix.com"];
        expectedURL = [NSURL URLWithString:@"https://api.flickr.com/services/rest?nojsoncallback=1&method=flickr.people.findByEmail&api_key=efce8c297a3e440e2c3e38d366abd3a5&format=json&find_email=theone@matrix.com"];
        
        expect(emailURL).to.equal(expectedURL);
        
        // test get public photos URL
        
        NSURL *publicPhotosURL = [MGFlickrAPI getPublicPhotosURLForUser:@"user1970" fromPage:@"1"];
        expectedURL = [NSURL URLWithString:@"https://api.flickr.com/services/rest?nojsoncallback=1&method=flickr.people.getPublicPhotos&api_key=efce8c297a3e440e2c3e38d366abd3a5&format=json&user_id=user1970&per_page=500&page=1"];
        
        expect(publicPhotosURL).to.equal(expectedURL);
        
        // test get info for photo URL
        
        NSURL *infoURL = [MGFlickrAPI getInfoURLForPhotoId:@"photoId123"];
        expectedURL = [NSURL URLWithString:@"https://api.flickr.com/services/rest?nojsoncallback=1&method=flickr.photos.getInfo&api_key=efce8c297a3e440e2c3e38d366abd3a5&format=json&photo_id=photoId123"];
        
        expect(infoURL).to.equal(expectedURL);
        
        // test get info for user URL
        
        NSURL *userInfoURL = [MGFlickrAPI getInfoURLForUserId:@"user1970"];
        expectedURL = [NSURL URLWithString:@"https://api.flickr.com/services/rest?nojsoncallback=1&method=flickr.people.getInfo&api_key=efce8c297a3e440e2c3e38d366abd3a5&format=json&user_id=user1970"];
        
        expect(userInfoURL).to.equal(expectedURL);
        
        // test get sizes URL for photo URL
        
        NSURL *sizesURL = [MGFlickrAPI getSizesURLForPhotoId:@"photoId123"];
        expectedURL = [NSURL URLWithString:@"https://api.flickr.com/services/rest?nojsoncallback=1&method=flickr.photos.getSizes&api_key=efce8c297a3e440e2c3e38d366abd3a5&format=json&photo_id=photoId123"];
        
        expect(sizesURL).to.equal(expectedURL);
    });
    
    describe(@"should test the flickr service class", ^{
        
        it(@"shoult test fetching a user with the flickr service by its email", ^{
            
            waitUntil(^(DoneCallback done) {
                
                [[MGFlickrService sharedService] fetchUserWithEmail:@"miguel.gazela@gmail.com" completionHandler:^(id object, NSError *error) {
                    
                    expect(object).to.beInstanceOf([MGFlickrUser class]);
                    done();
                }];
            });
        });
        
        it(@"should test fetching a user with the flickr service by its username", ^{
            
            waitUntil(^(DoneCallback done) {
                
                [[MGFlickrService sharedService] fetchUserWithUsername:@"miguel.gazela" completionHandler:^(id object, NSError *error) {
                    
                    expect(object).to.beInstanceOf([MGFlickrUser class]);
                    done();
                }];
            });
        });
        
        it(@"should fail fetching a non existing user", ^{
            
            waitUntil(^(DoneCallback done) {
                
                [[MGFlickrService sharedService] fetchUserWithUsername:@"madeupusernamebymiguelatflickretch" completionHandler:^(id object, NSError *error) {
                    
                    expect(object).to.beNil;
                    done();
                }];
            });
        });
        
        it(@"should fetch a users first page of public photos", ^{
            
            waitUntil(^(DoneCallback done) {
                
                [[MGFlickrService sharedService] fetchPublicPhotosForUserId:@"84669604@N05" completionHandler:^(NSArray *photos, NSError *error) {
                    
                    expect(photos.count).to.beGreaterThan(0);
                    
                    NSDictionary *firstPhotoInfo = [photos firstObject];
                    
                    expect([firstPhotoInfo objectForKey:@"title"]).notTo.beNil;
                    
                    done();
                }];
            });
        });
        
        
        
    });
    
});

SpecEnd