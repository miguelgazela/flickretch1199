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

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)block {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI.sharedAPI findByEmailURLForEmail:email]];
    
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

@end
