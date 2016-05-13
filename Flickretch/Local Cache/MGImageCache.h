//
//  MGImageCache.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGFlickrPhoto;

@interface MGImageCache : NSObject

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;

- (UIImage *)cachedImageForKey:(NSString *)key;

- (void)deleteImageForKey:(NSString *)key;

@end
