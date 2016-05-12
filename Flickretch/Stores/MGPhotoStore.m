//
//  MGPhotoStore.m
//  Flickretch
//
//  Created by Miguel Oliveira on 08/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <AFNetworking/AFImageDownloader.h>
#import <MagicalRecord/MagicalRecord.h>

#import "MGPhotoStore.h"
#import "MGImageCache.h"

#import "FlickrPhoto+CoreDataProperties.h"

#import "MGFlickrService.h"

#import "MGConstants.h"

@interface MGPhotoStore ()

@property (nonatomic, strong) MGImageCache *imageCache;

@end

@implementation MGPhotoStore

- (instancetype)init {
    if ((self = [super init])) {
        _imageCache = [[MGImageCache alloc] init];
    }
    return self;
}

+ (instancetype)sharedStore {
    
    static MGPhotoStore *sharedStore = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        sharedStore = [[self alloc] init];
    });
    
    return sharedStore;
}

- (BOOL)activeCache {
    
    NSNumber *localPhotosCachePreference = [[NSUserDefaults standardUserDefaults] objectForKey:kMGSettingsPreferenceLocalPhotosCache];
    return (localPhotosCachePreference && localPhotosCachePreference.boolValue);
}

- (void)getPhotoListForUserId:(NSString *)userId completionHandler:(MGPhotoStoreGetObjectsCompletionHandler)handler {
    
    NSMutableArray *photos = [NSMutableArray array];
    
    if ([self activeCache]) {
        
        NSPredicate *photoFilter = [NSPredicate predicateWithFormat:@"ownerId == %@", userId];
        
        NSArray *savedPhotos = [FlickrPhoto MR_findAllSortedBy:@"addedAt"
                              ascending:YES
                          withPredicate:photoFilter
                              inContext:[NSManagedObjectContext MR_defaultContext]];
        
        [photos addObjectsFromArray:savedPhotos];
    }
    
    [[MGFlickrService sharedService] fetchPublicPhotosForUserId:userId completionHandler:^(NSArray *photosInfo, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error fetching photos");
            handler(nil, error);
            
        } else {
            
            
            for (NSDictionary *photoInfo in photosInfo) {
                
                BOOL createPhoto = NO;
                
                if (![self activeCache]) {
                    createPhoto = YES;
                } else {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@ && ownerId == %@", [photoInfo objectForKey:@"id"], userId];
                    NSNumber *existingEntities = [FlickrPhoto MR_numberOfEntitiesWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
                    
                    // if there's no photo for this user with this id, create one
                    
                    if (existingEntities.integerValue == 0) {
                        createPhoto = YES;
                    }
                }
                
                if (createPhoto) {
                    
                    FlickrPhoto *flickrPhoto = [FlickrPhoto MR_createEntity];
                    flickrPhoto.identifier = [photoInfo objectForKey:@"id"];
                    flickrPhoto.title = [photoInfo objectForKey:@"title"];
                    flickrPhoto.ownerId = userId;
                    flickrPhoto.addedAt = [NSDate date];
                    
                    [photos addObject:flickrPhoto];
                }
            }
            
            handler(photos, error);
            
            NSError *mocError;
            [[NSManagedObjectContext MR_defaultContext] save:&mocError];
        }
    }];
}

- (void)getImageForPhoto:(FlickrPhoto *)photo forThumbnail:(BOOL)isThumbnail completionHandler:(MGPhotoStoreGetObjectCompletionHandler)handler {
    
    if ([self activeCache]) {
        
        NSString *keySuffix = isThumbnail ? @"small" : @"big";
        
        UIImage *cachedImage = [self.imageCache cachedImageForKey:[NSString stringWithFormat:@"%@-%@-%@", photo.identifier, photo.ownerId, keySuffix]];
        
        if (cachedImage) {
            
            handler(cachedImage, nil);
            return;
        }
    }
    
    [[MGFlickrService sharedService] fetchPhotoSizesForPhotoId:photo.identifier completionHandler:^(id fetchedPhotoInfo, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error fetching thumbnail image");
            handler(nil, error);
            return;
            
        } else {
            
            photo.smallestSizeURL = [fetchedPhotoInfo objectForKey:@"smallestSizeURL"];
            photo.biggestSizeURL = [fetchedPhotoInfo objectForKey:@"biggestSizeURL"];
            
            handler(photo, error);
            
            // download the image data for future use
            NSURLRequest *request;
            NSString *keySuffix;
            
            if (isThumbnail) {
                request = [NSURLRequest requestWithURL:photo.smallestSizeURL];
                keySuffix = @"small";
            } else {
                request = [NSURLRequest requestWithURL:photo.biggestSizeURL];
                keySuffix = @"big";
            }
            
            [[AFImageDownloader defaultInstance] downloadImageForURLRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responseObject) {
                [self.imageCache cacheImage:responseObject forKey:[NSString stringWithFormat:@"%@-%@-%@", photo.identifier, photo.ownerId, keySuffix]];
            } failure:nil];            
        }
    }];
}

- (void)saveImageForPhoto:(FlickrPhoto *)photo {
    
    if ([self activeCache]) {
        
        UIImage *cachedImage = [self.imageCache cachedImageForKey:[NSString stringWithFormat:@"%@-%@-big", photo.identifier, photo.ownerId]];
        
        if (cachedImage) {
            UIImageWriteToSavedPhotosAlbum(cachedImage, nil, nil, nil);
            return;
        }
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:photo.biggestSizeURL];
    
    [[AFImageDownloader defaultInstance] downloadImageForURLRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responseObject) {
        UIImageWriteToSavedPhotosAlbum(responseObject, nil, nil, nil);
    } failure:nil];
    
}

@end
