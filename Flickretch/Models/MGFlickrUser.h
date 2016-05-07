//
//  MGFlickrUser.h
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGFlickrUser : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSData *imageData;

- (instancetype)initWithUsername:(NSString *)username identifier:(NSString *)identifier;

@end
