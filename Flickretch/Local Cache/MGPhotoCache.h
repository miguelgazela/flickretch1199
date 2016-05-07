//
//  MGPhotoCache.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGPhotoCache : NSObject

+ (instancetype)sharedCache;

- (void)cacheURL:(NSURL *)url forPhotoId:(NSString *)photoId;

- (NSURL *)cachedURLForPhotoId:(NSString *)photoId;

@end