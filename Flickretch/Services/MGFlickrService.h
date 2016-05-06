//
//  MGFlickrService.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGFlickrUser;

typedef void (^MGFlickrServiceFetchUserCompletionHandler)(MGFlickrUser *user, NSError *error);

@interface MGFlickrService : NSObject

- (void)fetchUserWithEmail:(NSString *)email completionHandler:(MGFlickrServiceFetchUserCompletionHandler)block;



@end
