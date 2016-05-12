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
        
//    if ([self activeCache]) {
//                
//        NSArray *cachedPhotoList = [self.photoCache cachedPhotosForUserId:userId];
//        
//        if (cachedPhotoList) {
//            handler(cachedPhotoList, nil);
//            return;
//        }
//    }
    
    [[MGFlickrService sharedService] fetchPublicPhotosForUserId:userId completionHandler:^(NSArray *photosInfo, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error fetching photos");
            handler(nil, error);
            
        } else {
            
            NSMutableArray *photos = [NSMutableArray array];
            
            for (NSDictionary *photoInfo in photosInfo) {
                
                FlickrPhoto *flickrPhoto = [FlickrPhoto MR_createEntity];
                flickrPhoto.identifier = [photoInfo objectForKey:@"id"];
                flickrPhoto.title = [photoInfo objectForKey:@"title"];
                flickrPhoto.ownerId = userId;
                
                [photos addObject:flickrPhoto];
            }
            
            handler(photos, error);
//            [self.photoCache cachePhotoList:photos forUserId:userId];
        }

    }];
}

- (void)getPhoto:(FlickrPhoto *)partialPhoto forThumbnail:(BOOL)isThumbnail completionHandler:(MGPhotoStoreGetObjectCompletionHandler)handler {
    
    if ([self activeCache]) {
        
        NSString *keySuffix = isThumbnail ? @"small" : @"big";
        
        UIImage *cachedImage = [self.imageCache cachedImageForKey:[NSString stringWithFormat:@"%@-%@-%@", partialPhoto.identifier, partialPhoto.ownerId, keySuffix]];
        
        if (cachedImage) {
            
            if (isThumbnail) {
                partialPhoto.smallImage = cachedImage;
            } else {
                partialPhoto.bigImage = cachedImage;
            }
            
            handler(partialPhoto, nil);            
            return;
        }
    }
    
    [[MGFlickrService sharedService] fetchPhotoSizesForPhotoId:partialPhoto.identifier completionHandler:^(id fetchedPhotoInfo, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error fetching thumbnail image");
            
            handler(nil, error);
            return;
            
        } else {
            
            partialPhoto.smallestSizeURL = [fetchedPhotoInfo objectForKey:@"smallestSizeURL"];
            partialPhoto.biggestSizeURL = [fetchedPhotoInfo objectForKey:@"biggestSizeURL"];
            
            handler(partialPhoto, error);
            
            // download the image data for future use
            NSURLRequest *request;
            NSString *keySuffix;
            
            if (isThumbnail) {
                request = [NSURLRequest requestWithURL:partialPhoto.smallestSizeURL];
                keySuffix = @"small";
            } else {
                request = [NSURLRequest requestWithURL:partialPhoto.biggestSizeURL];
                keySuffix = @"big";
            }
            
            [[AFImageDownloader defaultInstance] downloadImageForURLRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responseObject) {
                [self.imageCache cacheImage:responseObject forKey:[NSString stringWithFormat:@"%@-%@-%@", partialPhoto.identifier, partialPhoto.ownerId, keySuffix]];
            } failure:nil];            
        }
    }];
}

- (void)saveImageForPhotoWithId:(NSString *)photoId {
    
//    [self getPhotoWithId:photoId forUser:userId completionHandler:^(NSArray *objects, NSError *error) {
//        
//        if (!error) {
//            
//            MGFlickrPhoto *photo = [objects firstObject];
//            NSURLRequest *request = [NSURLRequest requestWithURL:photo.biggestSizeURL];
//            
//            [[AFImageDownloader defaultInstance] downloadImageForURLRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *responseObject) {
//                
//                UIImageWriteToSavedPhotosAlbum(responseObject, nil, nil, nil);
//                                
//            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                
//            }];
//        }
//        
//        handler(nil, error);
//        
//    }];
}

@end
