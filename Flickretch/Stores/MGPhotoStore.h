//
//  MGPhotoStore.h
//  Flickretch
//
//  Created by Miguel Oliveira on 08/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MGPhotoStoreGetObjectCompletionHandler)(id object, NSError *error);

typedef void (^MGPhotoStoreGetObjectsCompletionHandler)(NSArray *objects, NSError *error);

@class FlickrPhoto;

@interface MGPhotoStore : NSObject

+ (instancetype)sharedStore;

- (void)getPhotoListForUserId:(NSString *)userId completionHandler:(MGPhotoStoreGetObjectsCompletionHandler)handler;

- (void)getPhoto:(FlickrPhoto *)partialPhoto forThumbnail:(BOOL)isThumbnail completionHandler:(MGPhotoStoreGetObjectCompletionHandler)handler;

- (void)saveImageForPhotoWithId:(NSString *)photoId;

@end
