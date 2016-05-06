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

@implementation MGFlickrService

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)block {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[MGFlickrAPI.sharedAPI findByEmailURLForEmail:email]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id data, NSError *error) {
        
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
