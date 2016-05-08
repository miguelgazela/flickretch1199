//
//  MGPhotoCache.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGFlickrPhoto;

@interface MGPhotoCache : NSObject

- (void)cachePhoto:(MGFlickrPhoto *)photo forUserId:(NSString *)userId;

- (void)cachePhotoList:(NSArray *)photoList forUserId:(NSString *)userId;

- (NSArray *)cachedPhotosForUserId:(NSString *)userId;

- (MGFlickrPhoto *)cachedPhotoWithPhotoId:(NSString *)photoId forUserId:(NSString *)userId;

@end
