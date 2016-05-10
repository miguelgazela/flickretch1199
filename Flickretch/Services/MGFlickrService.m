//
//  MGFlickrService.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <AFNetworking.h>

#import "MGFlickrService.h"

#import "MGFlickrAPI.h"
#import "MGFlickrUser.h"
#import "MGFlickrPhoto.h"

@interface MGFlickrService ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@end

@implementation MGFlickrService

- (instancetype)init {
    if ((self = [super init])) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];;
    }
    return self;
}

+ (instancetype)sharedService {
    
    static MGFlickrService *sharedService = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        sharedService = [[self alloc] init];
    });
    
    return sharedService;
}

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI findByEmailURLForEmail:email]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *response = data;
            NSString *status = [response objectForKey:@"stat"];
            
            MGFlickrUser *flickrUser = nil;
            
            if ([status isEqualToString:@"ok"]) {
                
                NSDictionary *userInfo = [response objectForKey:@"user"];
                NSDictionary *username = [userInfo objectForKey:@"username"];
                
                flickrUser = [[MGFlickrUser alloc] initWithUsername:[username objectForKey:@"_content"]
                                                         identifier:[userInfo objectForKey:@"nsid"]];
            }
            
            handler(flickrUser, error);
            
        } else {
            handler(nil, error);
        }
        
    }];
    [dataTask resume];
}

- (void)fetchUserWithUsername:(NSString *)username completionHandler:(MGFlickrServiceFetchUserCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI findByUsernameURLForUsername:username]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *response = data;
            NSString *status = [response objectForKey:@"stat"];
            
            MGFlickrUser *flickrUser = nil;
            
            if ([status isEqualToString:@"ok"]) {
                
                NSDictionary *userInfo = [response objectForKey:@"user"];
                
                flickrUser = [[MGFlickrUser alloc] initWithUsername:username
                                                         identifier:[userInfo objectForKey:@"nsid"]];
            }
            
            handler(flickrUser, error);
            
        } else {
            handler(nil, error);
        }
        
    }];
    [dataTask resume];
    
}

- (void)fetchInfoForUserId:(NSString *)userId {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getInfoURLForUserId:userId]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
       
        if (error) {
            
            NSLog(@"Error getting user information");
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
        }
        
    }];
    [dataTask resume];
}

- (void)fetchPublicPhotosForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchPublicPhotosCompletionHandler)handler {
    
    [self auxFetchPublicPhotosForUserId:userId fromPage:@"1" completionHandler:handler];
}

- (void)auxFetchPublicPhotosForUserId:(NSString *)userId fromPage:(NSString *)page completionHandler:(MGFlickrServiceFetchPublicPhotosCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getPublicPhotosURLForUser:userId fromPage:page]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *response = data;
            NSDictionary *photosPayload = [response objectForKey:@"photos"];
            
            NSArray *photos = [photosPayload objectForKey:@"photo"];
            
            if ([photos isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *flickrPhotos = [NSMutableArray array];
                
                for(NSDictionary *photoInfo in photos) {
                    
                    MGFlickrPhoto *flickrPhoto = [[MGFlickrPhoto alloc] initWithId:[photoInfo objectForKey:@"id"]
                                                                             title:[photoInfo objectForKey:@"title"]
                                                                        andOwnerId:userId];
                    
                    [flickrPhotos addObject:flickrPhoto];
                }
                
                handler(flickrPhotos, error);
                
                NSInteger currentPage = [[photosPayload objectForKey:@"page"] integerValue];
                NSInteger totalPages = [[photosPayload objectForKey:@"pages"] integerValue];
                
                if (currentPage < totalPages) {
                    
                    NSInteger nextPage = currentPage + 1;
                    
                    [self auxFetchPublicPhotosForUserId:userId fromPage:[NSString stringWithFormat:@"%ld", (long)nextPage] completionHandler:handler];
                }
            }
            
        } else {
            handler(nil, error);
        }
    }];
    [dataTask resume];
}

- (void)fetchInfoForPhotoWithId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getInfoURLForPhotoId:photoId]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
                    
            handler(nil, error);
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [data objectForKey:@"stat"];
            
            if ([status isEqualToString:@"ok"]) {
                
                NSDictionary *photoInfo = [data objectForKey:@"photo"];
                handler(photoInfo, error);
                
                return;
            }
        }
                
        handler(nil, error);
        
    }];
    [dataTask resume];
}

- (void)fetchPhotoWithPhotoId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchPhotoCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getSizesURLForPhotoId:photoId]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [data objectForKey:@"stat"];
            
            if ([status isEqualToString:@"ok"]) {
                
                MGFlickrPhoto *photo = [[MGFlickrPhoto alloc] init];
                NSArray *allSizes = [[data objectForKey:@"sizes"] objectForKey:@"size"];
                
                NSURL *smallestSizeURL = nil;
                NSURL *averageSizeURL = nil;
                NSURL *biggestSizeURL = nil;
                NSInteger smallestSize = NSIntegerMax;
                NSInteger biggestSize = NSIntegerMin;
                
                for (NSDictionary *size in allSizes) {
                    
                    NSString *sizeLabel = [size objectForKey:@"label"];
                    NSURL *url = [NSURL URLWithString:[size objectForKey:@"source"]];
                    NSInteger height = [[size objectForKey:@"height"] integerValue];
                    NSInteger width = [[size objectForKey:@"width"] integerValue];
                    
                    if ((height * width) > biggestSize) {
                        biggestSizeURL = url;
                        biggestSize = (height * width);
                    } else if ((height * width) < smallestSize) {
                        smallestSizeURL = url;
                        smallestSize = (height * width);
                    }
                    
                    if ([sizeLabel isEqualToString:@"Thumbnail"] || [sizeLabel isEqualToString:@"Large Square"]) {
                        smallestSizeURL = url;
                    }
                    
                    if (averageSizeURL == nil) {
                        
                        if ([sizeLabel isEqualToString:@"Medium 800"]
                            || [sizeLabel isEqualToString:@"Large"]
                            || [sizeLabel isEqualToString:@"Large 1600"]
                            || [sizeLabel isEqualToString:@"Large 2048"])
                        {
                            averageSizeURL = url;
                        }
                    }
                }
                
                if (averageSizeURL == nil) {
                    averageSizeURL = biggestSizeURL;
                }
                
                [photo setURLs:@[smallestSizeURL, averageSizeURL, biggestSizeURL]];
                
                handler(photo, error);
                return;
            }
        }
        
        handler(nil, error);
    }];
    [dataTask resume];
}

@end
