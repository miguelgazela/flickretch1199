//
//  MGFlickrService.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGFlickrUser;

typedef void (^MGFlickrServiceFetchUserCompletionHandler)(MGFlickrUser *user, NSError *error);

typedef void (^MGFlickrServiceFetchPublicPhotosCompletionHandler)(NSArray *photos, NSError *error);

typedef void (^MGFlickrServiceFetchPhotoThumbnailCompletionHandler)(NSURL *imageURL, NSError *error);

@interface MGFlickrService : NSObject

+ (instancetype)sharedService;

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)block;

- (void)fetchInfoForUserId:(NSString *)userId;

- (void)fetchPublicPhotosForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchPublicPhotosCompletionHandler)block;

- (void)fetchPhotoThumbnailURLForPhotoId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchPhotoThumbnailCompletionHandler)block;

@end
