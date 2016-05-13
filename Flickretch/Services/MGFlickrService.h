//
//  MGFlickrService.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGFlickrUser, FlickrPhoto;

typedef void (^MGFlickrServiceFetchObjectCompletionHandler)(id object, NSError *error);

typedef void (^MGFlickrServiceFetchObjectsCompletionHandler)(NSArray *photos, NSError *error);


@interface MGFlickrService : NSObject


+ (instancetype)sharedService;

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler;

- (void)fetchUserWithUsername:(NSString *)username completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler;

- (void)fetchPublicPhotosForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchObjectsCompletionHandler)handler;

- (void)fetchPhotoSizesForPhotoId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler;


@end
