//
//  MGContactStore.h
//  Flickretch
//
//  Created by Miguel Oliveira on 09/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MGContactStoreGetObjectsCompletionHandler)(NSArray *objects, NSError *error);

@interface MGContactStore : NSObject

+ (instancetype)sharedStore;

- (void)getAddressBookFlickrUsersWithCompletionHandler:(MGContactStoreGetObjectsCompletionHandler)handler;

- (void)getAwesomeFlickrUsersWithCompletionHandler:(MGContactStoreGetObjectsCompletionHandler)handler;

@end
