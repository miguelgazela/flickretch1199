//
//  M3FlickrPhoto.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGFlickrPhoto : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *ownerId;

- (instancetype)initWithId:(NSString *)identifier title:(NSString *)title andOwnerId:(NSString *)ownerId;

@end
