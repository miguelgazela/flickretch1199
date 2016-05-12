//
//  MGContactStore.m
//  Flickretch
//
//  Created by Miguel Oliveira on 09/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Contacts/Contacts.h>

#import "MGContactStore.h"

#import "MGFlickrService.h"
#import "MGFlickrUser.h"

@implementation MGContactStore

+ (instancetype)sharedStore {
    
    static MGContactStore *sharedStore = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        sharedStore = [[self alloc] init];
    });
    
    return sharedStore;
}

- (void)getAddressBookFlickrUsersWithCompletionHandler:(MGContactStoreGetObjectsCompletionHandler)handler {
    
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    
    // fetch all contacts with a flickr account from the address book
    
    [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
        
        if (error) {
            
            NSLog(@"error requesting for contacts");
            handler(nil, error);
            
        } else {
            
            if (granted) {
                
                NSArray *desiredKeys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey, CNContactEmailAddressesKey, CNContactImageDataKey];
                NSString *containerId = addressBook.defaultContainerIdentifier;
                NSPredicate *searchPredicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
                NSError *error;
                
                NSArray *contacts = [addressBook unifiedContactsMatchingPredicate:searchPredicate keysToFetch:desiredKeys error:&error];
                
                if (error) {
                    
                    NSLog(@"Error fetching contacts %@", error);
                    
                } else {
                    
                    for (CNContact *contact in contacts) {
                        
                        for (CNLabeledValue *labeledValue in contact.emailAddresses) {
                            
                            [[MGFlickrService sharedService] fetchUserWithEmail:labeledValue.value completionHandler:^(MGFlickrUser *user, NSError *error) {
                                
                                if (error) {
                                    
                                    NSLog(@"Error fetching user %@", error);
                                    handler(nil, error);
                                    
                                } else {
                                    
                                    if (user) {
                                        
                                        [user setName:[NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName]];
                                        [user setEmail:labeledValue.value];
                                        [user setIsRemote:NO];
                                        
                                        handler(@[user], error);
                                    }
                                }
                            }];
                        }
                    }
                }
            } else {
                handler(nil, error);
            }
        }
    }];
}

- (void)getAwesomeFlickrUsersWithCompletionHandler:(MGContactStoreGetObjectsCompletionHandler)handler {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"knownflickrusers" ofType:@"plist"];
    
    NSArray *awesomeFlickrUsers = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    if (awesomeFlickrUsers) {
                
        for (NSString *username in awesomeFlickrUsers) {
    
            [[MGFlickrService sharedService] fetchUserWithUsername:username completionHandler:^(MGFlickrUser *user, NSError *error) {
    
                if (error) {
    
                    NSLog(@"error fetching user by username");
    
                } else {
    
                    if (user) {
    
                        [user setName:username];
                        [user setIsRemote:YES];
    
                        handler(@[user], error);
    
                        return;
                    }
                }
                
                handler(nil, error);
            }];
        }
        
    } else {
        handler(nil, [[NSError alloc] initWithDomain:@"Error reading plist file" code:666 userInfo:nil]);
    }
}

@end
