//
//  MGPhotoCache.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGPhotoCache.h"

@interface MGPhotoCache ()

@property (nonatomic, strong) NSCache *photoURLCache;

@end

@implementation MGPhotoCache

- (instancetype)init {
    if ((self = [super init])) {
        _photoURLCache = [[NSCache alloc] init];
    }
    return self;
}

+ (instancetype)sharedCache {
    
    static MGPhotoCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    
    return sharedCache;
}

- (void)cacheURL:(NSURL *)url forPhotoId:(NSString *)photoId {
    [self.photoURLCache setObject:url forKey:photoId];
}

- (NSURL *)cachedURLForPhotoId:(NSString *)photoId {
    return [self.photoURLCache objectForKey:photoId];
}

@end
