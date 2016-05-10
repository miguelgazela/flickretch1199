//
//  MGContactsTableViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 06/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGContactsTableViewController.h"

#import "MGProfileViewController.h"

#import "MGContactTableViewCell.h"

#import "MGContactStore.h"

#import "MGFlickrUser.h"


@interface MGContactsTableViewController ()

@property (nonatomic, strong) NSMutableArray<MGFlickrUser *> *flickrizedContacts;

@end

@implementation MGContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self setFlickrizedContacts:[NSMutableArray array]];
    
    [[MGContactStore sharedStore] getAwesomeFlickrUsersWithCompletionHandler:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error getting address book users");
            // TODO: warn user
            
        } else {
            
            for (MGFlickrUser *flickrUser in objects) {
                
                [self.flickrizedContacts addObject:flickrUser];
            }
            
            [self.flickrizedContacts sortUsingComparator:^(MGFlickrUser *user1, MGFlickrUser *user2) {
                return (NSComparisonResult)[user1.name compare:user2.name];
            }];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }
        
    }];
    
    [[MGContactStore sharedStore] getAddressBookFlickrUsersWithCompletionHandler:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"Error getting address book users");
            // TODO: warn user
            
        } else {
            
            for (MGFlickrUser *flickrUser in objects) {
                
                [self.flickrizedContacts addObject:flickrUser];
            }
            
            [self.flickrizedContacts sortUsingComparator:^(MGFlickrUser *user1, MGFlickrUser *user2) {
                return (NSComparisonResult)[user1.name compare:user2.name];
            }];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
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
    
    MGContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactViewCell" forIndexPath:indexPath];
    MGFlickrUser *userForCell = [self.flickrizedContacts objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = userForCell.name;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", userForCell.username];
    
    if (userForCell.isRemote) {
        [cell.iconImageView setImage:[UIImage imageNamed:@"FlickrUserIcon"]];
    } else {
        [cell.iconImageView setImage:[UIImage imageNamed:@"AddressBookUserIcon"]];
    }
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
    MGFlickrUser *selectedUser = [self.flickrizedContacts objectAtIndex:selectedRow];
    
    MGProfileViewController *viewController = (MGProfileViewController *)segue.destinationViewController;
    viewController.user = selectedUser;
}

@end
