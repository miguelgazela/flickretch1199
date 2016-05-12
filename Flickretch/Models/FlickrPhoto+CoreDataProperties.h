//
//  FlickrPhoto+CoreDataProperties.h
//  
//
//  Created by Miguel Oliveira on 11/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FlickrPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlickrPhoto (CoreDataProperties)

@property (nullable, nonatomic, retain) NSURL *biggestSizeURL;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSString *ownerId;
@property (nullable, nonatomic, retain) NSURL *smallestSizeURL;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
