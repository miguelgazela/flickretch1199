//
//  MGImageCache.m
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGImageCache.h"

@interface MGImageCache ()

@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation MGImageCache

- (instancetype)init {
    if ((self = [super init])) {
        _imageCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key {
        
    [self.imageCache setObject:image forKey:key];
    
    NSURL *localPathURL = [self localImageURLForKey:key];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToURL:localPathURL atomically:YES];
}

- (UIImage *)cachedImageForKey:(NSString *)key {
    
    UIImage *cachedImage = [self.imageCache objectForKey:key];
    
    if (cachedImage) {
        return cachedImage;
    }
    
    NSURL *savedPathURL = [self localImageURLForKey:key];
    UIImage *savedImage = [UIImage imageWithContentsOfFile:savedPathURL.path];
    
    return savedImage;
}

- (NSURL *)localImageURLForKey:(NSString *)key {
    
    NSArray *directories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories firstObject];
    
    return [directory URLByAppendingPathComponent:key];
}


@end
