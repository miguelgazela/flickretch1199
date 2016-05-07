//
//  MGFlickrAPI.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGFlickrAPI : NSObject

+ (NSURL *)findByUsernameURLForUsername:(NSString *)username;

+ (NSURL *)findByEmailURLForEmail:(NSString *)email;

+ (NSURL *)getPublicPhotosURLForUser:(NSString *)userId;

+ (NSURL *)getInfoURLForUserId:(NSString *)userId;

+ (NSURL *)getSizesURLForPhotoId:(NSString *)photoId;

@end
