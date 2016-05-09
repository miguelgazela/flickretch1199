//
//  MGFlickrService.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGFlickrUser, MGFlickrPhoto;

typedef void (^MGFlickrServiceFetchObjectCompletionHandler)(id object, NSError *error);

typedef void (^MGFlickrServiceFetchUserCompletionHandler)(MGFlickrUser *user, NSError *error);

typedef void (^MGFlickrServiceFetchPublicPhotosCompletionHandler)(NSArray *photos, NSError *error);

typedef void (^MGFlickrServiceFetchPhotoCompletionHandler)(MGFlickrPhoto *photo, NSError *error);


@interface MGFlickrService : NSObject


+ (instancetype)sharedService;

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)handler;

- (void)fetchUserWithUsername:(NSString *)username completionHandler:(MGFlickrServiceFetchUserCompletionHandler)handler;

- (void)fetchInfoForUserId:(NSString *)userId;

- (void)fetchPublicPhotosForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchPublicPhotosCompletionHandler)handler;

- (void)fetchInfoForPhotoWithId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler;

- (void)fetchPhotoWithPhotoId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchPhotoCompletionHandler)handler;


@end
