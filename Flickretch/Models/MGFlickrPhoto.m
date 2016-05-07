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

@end
