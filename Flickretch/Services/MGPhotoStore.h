//
//  MGPhotoStore.h
//  Flickretch
//
//  Created by Miguel Oliveira on 08/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MGPhotoStoreGetObjectsCompletionHandler)(NSArray *objects, NSError *error);

@class MGPhotoCache;


@interface MGPhotoStore : NSObject

@property (nonatomic, strong) MGPhotoCache *photoCache;

+ (instancetype)sharedStore;

- (void)getPhotoListForUserId:(NSString *)userId completionHandler:(MGPhotoStoreGetObjectsCompletionHandler)handler;

- (void)getPhotoWithId:(NSString *)photoId forUser:(NSString *)userId completionHandler:(MGPhotoStoreGetObjectsCompletionHandler)handler;

@end
