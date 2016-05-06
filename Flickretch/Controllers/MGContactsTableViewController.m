//
//  MGContactsTableViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <Contacts/Contacts.h>

#import "MGContactsTableViewController.h"

#import "MGFlickrService.h"
#import "MGFlickrUser.h"


@interface MGContactsTableViewController ()

@property (nonatomic, strong) NSMutableArray<MGFlickrUser *> *flickrizedContacts;

@end

@implementation MGContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFlickrizedContacts:[NSMutableArray array]];
    
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    
    [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if (granted) {
            
            NSArray *desiredKeys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey, CNContactEmailAddressesKey];
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
                            } else {
                                
                                if (user) {
                                    
                                    [user setName:[NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName]];
                                    [user setEmail:labeledValue.value];
                                                                        
                                    [self.flickrizedContacts addObject:user];
                                    
                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                        [self.tableView reloadData];
                                    }];
                                }
                            }
                        }];
                    }
                }
            }
        } else {
            
        }
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.flickrizedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.flickrizedContacts objectAtIndex:indexPath.row].name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", [self.flickrizedContacts objectAtIndex:indexPath.row].username];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
