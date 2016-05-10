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
    
    return self.smallestSizeURL || self.averageSizeURL || self.biggestSizeURL;
}

- (void)setURLs:(NSArray *)urls {
    
    NSAssert([urls count] == 3, @"Should have at least 3 URLS");
    
    [self setSmallestSizeURL:[urls objectAtIndex:0]];
    [self setAverageSizeURL:[urls objectAtIndex:1]];
    [self setBiggestSizeURL:[urls objectAtIndex:2]];
}

@end
