//
//  MGPhotoCache.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGPhotoCache.h"

#import "MGFlickrPhoto.h"

@interface MGPhotoCache ()

@property (nonatomic, strong) NSCache *photoCache;

@end

@implementation MGPhotoCache

- (instancetype)init {
    if ((self = [super init])) {
        _photoCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)cachePhoto:(MGFlickrPhoto *)photo forUserId:(NSString *)userId {
    
    NSMutableDictionary *userCache = [self.photoCache objectForKey:userId];
    
    if (userCache) {
        
        [userCache setObject:photo forKey:photo.identifier];
        
    } else {
        
        NSMutableDictionary *userCache = [NSMutableDictionary dictionary];
        [userCache setObject:photo forKey:photo.identifier];
        
        [self.photoCache setObject:userCache forKey:userId];
    }
}

- (void)cachePhotoList:(NSArray *)photoList forUserId:(NSString *)userId {
    
    for (id photo in photoList) {
        [self cachePhoto:photo forUserId:userId];
    }
}

- (NSArray *)cachedPhotosForUserId:(NSString *)userId {
    
    NSMutableDictionary *userCache = [self.photoCache objectForKey:userId];
    
    if (userCache) {
        
        NSMutableArray *allPhotos = [NSMutableArray array];
        
        for (NSString *key in userCache.allKeys) {
            [allPhotos addObject:[userCache objectForKey:key]];
        }
        
        return [allPhotos copy];
    }
    
    return nil;
}

- (MGFlickrPhoto *)cachedPhotoWithPhotoId:(NSString *)photoId forUserId:(NSString *)userId {
    
    NSMutableDictionary *userCache = [self.photoCache objectForKey:userId];
    
    if (userCache) {
        
        return [userCache objectForKey:photoId];
    }
    
    return nil;
}


@end
