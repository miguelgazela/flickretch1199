//
//  MGPhotoStore.m
//  Flickretch
//
//  Created by Miguel Oliveira on 08/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGPhotoStore.h"
#import "MGPhotoCache.h"

#import "MGFlickrPhoto.h"

#import "MGFlickrService.h"

#import "MGConstants.h"


@implementation MGPhotoStore

- (instancetype)init {
    if ((self = [super init])) {
        _photoCache = [[MGPhotoCache alloc] init];
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
    
    if ([self activeCache]) {
                
        NSArray *cachedPhotoList = [self.photoCache cachedPhotosForUserId:userId];
        
        if (cachedPhotoList) {
            handler(cachedPhotoList, nil);
            return;
        }
    }
    
    [[MGFlickrService sharedService] fetchPublicPhotosForUserId:userId completionHandler:^(NSArray *photos, NSError *error) {
        
        if (error) {
            NSLog(@"Error fetching photos");
        }
        
        handler(photos, error);
        [self.photoCache cachePhotoList:photos forUserId:userId];
    }];
}

- (void)getPhotoWithId:(NSString *)photoId forUser:(NSString *)userId completionHandler:(MGPhotoStoreGetObjectsCompletionHandler)handler {
    
    if ([self activeCache]) {
        
        MGFlickrPhoto *cachedPhoto = [[self photoCache] cachedPhotoWithPhotoId:photoId forUserId:userId];
        
        if (cachedPhoto) {
            
            if ([cachedPhoto hasValidRemoteURL]) {
                
                handler(@[cachedPhoto], nil);
                return;
            }
        }
    }
        
    [[MGFlickrService sharedService] fetchInfoForPhotoWithId:photoId completionHandler:^(id object, NSError *error) {
        
        if (error) {
            
            NSLog(@"error fetching photo info");
            
            handler(nil, error);
            return;
        }
        
        NSDictionary *photoInfo = object;
        NSString *photoTitle = [[photoInfo objectForKey:@"title"] objectForKey:@"_content"];
        
        MGFlickrPhoto *photo = [[MGFlickrPhoto alloc] initWithId:photoId title:photoTitle andOwnerId:userId];
        
        [[MGFlickrService sharedService] fetchPhotoWithPhotoId:photoId completionHandler:^(MGFlickrPhoto *fetchedPhoto, NSError *error) {
    
            if (error) {
                
                NSLog(@"Error fetching thumbnail image");
                
                handler(nil, error);
                return;
                
            } else {
    
                [photo setURLs:@[fetchedPhoto.smallestSizeURL, fetchedPhoto.averageSizeURL, fetchedPhoto.biggestSizeURL]];
                handler(@[photo], error);
            
                [self.photoCache cachePhoto:photo forUserId:userId];
            }
        }];
    }];
}

@end
