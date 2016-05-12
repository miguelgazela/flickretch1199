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

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI findByEmailURLForEmail:email]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id object, NSError *error) {
        
        if (error) {
            handler(nil, error);
            return;
        }
        
        if ([self isValidResponse:object]) {
            
            NSDictionary *userInfo = [object objectForKey:@"user"];
            NSDictionary *username = [userInfo objectForKey:@"username"];
            
            MGFlickrUser *flickrUser = [[MGFlickrUser alloc] initWithUsername:[username objectForKey:@"_content"]
                                                     identifier:[userInfo objectForKey:@"nsid"]];
            
            handler(flickrUser, error);
            
        } else {
            handler(nil, error);
        }
        
    }];
    [dataTask resume];
}

- (void)fetchUserWithUsername:(NSString *)username completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI findByUsernameURLForUsername:username]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id object, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([self isValidResponse:object]) {
            
            NSDictionary *userInfo = [object objectForKey:@"user"];
            
            MGFlickrUser *flickrUser = [[MGFlickrUser alloc] initWithUsername:username
                                                                   identifier:[userInfo objectForKey:@"nsid"]];
            
            handler(flickrUser, error);
            
        } else {
            handler(nil, error);
        }
        
    }];
    [dataTask resume];
    
}

- (void)fetchInfoForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getInfoURLForUserId:userId]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
       
        if (error) {
            
            NSLog(@"Error getting user information");
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSLog(@"Data: %@", data);
        }
        
        handler(nil, error);
        
    }];
    [dataTask resume];
}

- (void)fetchPublicPhotosForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchObjectsCompletionHandler)handler {
    
    [self auxFetchPublicPhotosForUserId:userId fromPage:@"1" completionHandler:handler];
}

- (void)auxFetchPublicPhotosForUserId:(NSString *)userId fromPage:(NSString *)page completionHandler:(MGFlickrServiceFetchObjectsCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getPublicPhotosURLForUser:userId fromPage:page]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id object, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([self isValidResponse:object]) {
            
            NSDictionary *data = object;
            NSDictionary *photosPayload = [data objectForKey:@"photos"];
            
            NSArray *photos = [photosPayload objectForKey:@"photo"];
            
            if ([photos isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *flickrPhotos = [NSMutableArray array];
                
                for(NSDictionary *photoInfo in photos) {
                    [flickrPhotos addObject:@{@"id": [photoInfo objectForKey:@"id"], @"title": [photoInfo objectForKey:@"title"]}];
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
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id object, NSError *error) {
        
        if (error) {
                    
            handler(nil, error);
            return;
        }
        
        if ([self isValidResponse:object]) {
            
            NSDictionary *photoInfo = [object objectForKey:@"photo"];
            handler(photoInfo, error);
            
        } else {
            handler(nil, error);
        }
        
    }];
    [dataTask resume];
}

- (void)fetchPhotoSizesForPhotoId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchObjectCompletionHandler)handler {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getSizesURLForPhotoId:photoId]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id object, NSError *error) {
        
        if (error) {
            
            handler(nil, error);
            return;
        }
        
        if ([self isValidResponse:object]) {
            
            NSArray *allSizes = [[object objectForKey:@"sizes"] objectForKey:@"size"];
            
            NSURL *smallestSizeURL = nil;
            NSURL *biggestSizeURL = nil;
            NSInteger smallestSize = NSIntegerMax;
            NSInteger biggestSize = NSIntegerMin;
            
            for (NSDictionary *size in allSizes) {
                
                NSURL *url = [NSURL URLWithString:[size objectForKey:@"source"]];
                NSInteger height = [[size objectForKey:@"height"] integerValue];
                NSInteger width = [[size objectForKey:@"width"] integerValue];
                
                if ((height * width) > biggestSize) {
                    biggestSizeURL = url;
                    biggestSize = (height * width);
                }
                
                if ((height * width) > (100 * 80) && (height * width) < smallestSize) {
                    smallestSizeURL = url;
                    smallestSize = (height * width);
                }
            }
            
            handler(@{@"smallestSizeURL": smallestSizeURL, @"biggestSizeURL": biggestSizeURL}, error);
            
        } else {
            handler(nil, error);
        }
        
    }];
    [dataTask resume];
}

- (BOOL)isValidResponse:(id)object {
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *data = object;
        NSString *status = [data objectForKey:@"stat"];
        
        if ([status isEqualToString:@"ok"]) {
            return YES;
        }
    }
    
    return NO;
}

@end
