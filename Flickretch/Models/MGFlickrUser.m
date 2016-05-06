//
//  MGFlickrUser.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGFlickrUser.h"

@implementation MGFlickrUser

- (instancetype)initWithUsername:(NSString *)username identifier:(NSString *)identifier {
    if ((self = [super init])) {
        
        _username = username;
        _identifier = identifier;
    }
    return self;
}

@end
