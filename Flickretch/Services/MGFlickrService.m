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

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)block {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI findByEmailURLForEmail:email]];
    
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            block(nil, error);
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
            
            block(flickrUser, error);
            
        } else {
            block(nil, error);
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

- (void)fetchPublicPhotosForUserId:(NSString *)userId completionHandler:(MGFlickrServiceFetchPublicPhotosCompletionHandler)block {
    
    [self auxFetchPublicPhotosForUserId:userId fromPage:@"1" completionHandler:block];
}

- (void)auxFetchPublicPhotosForUserId:(NSString *)userId fromPage:(NSString *)page completionHandler:(MGFlickrServiceFetchPublicPhotosCompletionHandler)block {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getPublicPhotosURLForUser:userId fromPage:page]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            block(nil, error);
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
                
                block(flickrPhotos, error);
                
                NSInteger currentPage = [[photosPayload objectForKey:@"page"] integerValue];
                NSInteger totalPages = [[photosPayload objectForKey:@"pages"] integerValue];
                
                if (currentPage < totalPages) {
                    
                    NSInteger nextPage = currentPage + 1;
                    
                    [self auxFetchPublicPhotosForUserId:userId fromPage:[NSString stringWithFormat:@"%d", nextPage] completionHandler:block];
                }
            }
            
        } else {
            block(nil, error);
        }
    }];
    [dataTask resume];
}

- (void)fetchPhotoThumbnailURLForPhotoId:(NSString *)photoId completionHandler:(MGFlickrServiceFetchPhotoThumbnailCompletionHandler)block {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI getSizesURLForPhotoId:photoId]];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
        if (error) {
            
            block(nil, error);
            return;
        }
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSString *status = [data objectForKey:@"stat"];
            
            if ([status isEqualToString:@"ok"]) {
                
                NSArray *allSizes = [[data objectForKey:@"sizes"] objectForKey:@"size"];
                
                for (NSDictionary *size in allSizes) {
                    
                    if ([[size objectForKey:@"label"] isEqualToString:@"Large Square"]) {
                        
                        NSURL *photoURL = [NSURL URLWithString:[size objectForKey:@"source"]];
                        
                        block(photoURL, error);
                        return;
                    }
                }
            }
        }
        
        block(nil, error);
    }];
    [dataTask resume];
}

@end
