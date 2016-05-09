//
//  M3FlickrPhoto.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGFlickrPhoto.h"

@implementation MGFlickrPhoto

- (instancetype)initWithId:(NSString *)identifier title:(NSString *)title andOwnerId:(NSString *)ownerId {
    if ((self = [super init])) {
        _identifier = identifier;
        _title = title;
        _ownerId = ownerId;
    }
    return self;
}

- (BOOL)hasValidRemoteURL {
    
    return self.thumbnailRemoteURL || self.largeRemoteURL || self.originalRemoteURL;
}

- (NSURL *)smallestSizeURL {
    
    if (self.thumbnailRemoteURL) {
        return self.thumbnailRemoteURL;
    } else if (self.largeRemoteURL) {
        return self.largeRemoteURL;
    } else if (self.originalRemoteURL) {
        return self.originalRemoteURL;
    }
    
    return nil;
}

- (NSURL *)largestSizeURL {
        
    if (self.largeRemoteURL) {
        return self.largeRemoteURL;
    } else if (self.thumbnailRemoteURL) {
        return self.thumbnailRemoteURL;
    }
    
    return nil;
}

- (NSURL *)originalSizeURL {
    return self.originalRemoteURL;
}

- (void)setURLs:(NSArray *)urls {
    
    NSAssert([urls count] == 3, @"Should have at least 3 URLS");
    
    [self setThumbnailRemoteURL:[urls objectAtIndex:0]];
    [self setLargeRemoteURL:[urls objectAtIndex:1]];
    [self setOriginalRemoteURL:[urls objectAtIndex:2]];
}

@end
