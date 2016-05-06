//
//  MGFlickrAPI.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGFlickrAPI.h"

@interface MGFlickrAPI ()

@end

static NSString *kMGFlickrAPIBaseURL = @"https://api.flickr.com/services/rest";
static NSString *kMGFlickrAPIKey = @"efce8c297a3e440e2c3e38d366abd3a5";

static NSString *kMGFlickrAPIFindByUsernameEndpoint = @"flickr.people.findByUsername";
static NSString *kMGFlickrAPIFindByEmailEndpoint = @"flickr.people.findByEmail";
static NSString *kMGFlickrAPIGetPublicPhotosEndpoint = @"flickr.people.getPublicPhotos";
static NSString *kMGFlickrAPIGetInfoEndpoint = @"flickr.people.getInfo";
static NSString *kMGFlickrAPIGetSizesEndpoint = @"flickr.people.getSizes";

@implementation MGFlickrAPI

+ (instancetype)sharedAPI {
    
    static MGFlickrAPI *sharedAPI = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedAPI = [[self alloc] init];
    });
    
    return sharedAPI;
}


#pragma mark - Private Methods

- (NSURL *)urlForEndpoint:(NSString *)endpoint withArguments:(NSDictionary *)arguments {
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:kMGFlickrAPIBaseURL];
    
    // provide arguments for the API
    
    NSMutableArray *argumentsForAPI = [NSMutableArray array];
    
    NSDictionary *requiredArguments = @{
                                        @"method": endpoint,
                                        @"format": @"json",
                                        @"api_key": kMGFlickrAPIKey,
                                        @"nojsoncallback": @"1"
                                        };
    
    for (NSString *key in [requiredArguments allKeys]) {
        [argumentsForAPI addObject:[[NSURLQueryItem alloc] initWithName:key value:[requiredArguments objectForKey:key]]];
    }
    
    if (arguments != nil) {
        
        for (NSString *key in [arguments allKeys]) {
            [argumentsForAPI addObject:[[NSURLQueryItem alloc] initWithName:key value:[arguments objectForKey:key]]];
        }
    }
    
    [components setQueryItems:argumentsForAPI];
    
    return [components URL];
}

#pragma mark - Public URL Methods

- (NSURL *)findByUsernameURLForUsername:(NSString *)username {
    return [self urlForEndpoint:kMGFlickrAPIFindByUsernameEndpoint withArguments:@{@"username": username}];
}

- (NSURL *)findByEmailURLForEmail:(NSString *)email {
    return [self urlForEndpoint:kMGFlickrAPIFindByEmailEndpoint withArguments:@{@"find_email": email}];
}

- (NSURL *)getPublicPhotosURL {
    return [self urlForEndpoint:kMGFlickrAPIGetPublicPhotosEndpoint withArguments:nil];
}

- (NSURL *)getInfoURL {
    return [self urlForEndpoint:kMGFlickrAPIGetInfoEndpoint withArguments:nil];
}

- (NSURL *)getSizesURL {
    return [self urlForEndpoint:kMGFlickrAPIGetSizesEndpoint withArguments:nil];
}



@end
