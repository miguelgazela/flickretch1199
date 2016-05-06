//
//  MGFlickrAPI.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGFlickrAPI : NSObject

+ (instancetype)sharedAPI;


- (NSURL *)findByUsernameURLForUsername:(NSString *)username;

- (NSURL *)findByEmailURLForEmail:(NSString *)email;

- (NSURL *)getPublicPhotosURL;

- (NSURL *)getInfoURL;

- (NSURL *)getSizesURL;

@end
