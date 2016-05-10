//
//  SettingsViewController.m
//  Flickretch
//
//  Created by Miguel Oliveira on 10/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import "MGSettingsViewController.h"

#import "MGFlickrService.h"
#import "MGFlickrUser.h"

@interface MGSettingsViewController ()

@end

@implementation MGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *defaultAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultAccount"];
    self.defaultUsername.text = defaultAccount;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)checkIfUserExists {
    
    [[self activityIndicator] startAnimating];
    self.informationLabel.text = @"Checking if user exists...";
    [self.informationLabel setHidden:NO];
    
    NSString *newUsername = self.usernameTextField.text;
    
    if (![newUsername isEqualToString:@""]) {
        
        [[MGFlickrService sharedService] fetchUserWithUsername:newUsername completionHandler:^(MGFlickrUser *user, NSError *error) {
            
            if (error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self.activityIndicator stopAnimating];
                    self.informationLabel.text = @"Error checking if user exists...";
                }];
                
                
            } else {
                
                if (user) {
                                        
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [self.activityIndicator stopAnimating];
                        
                        self.informationLabel.text = @"";
                        [self.informationLabel setHidden:YES];
                        [self.usernameTextField setText:@""];
                        self.defaultUsername.text = user.username;
                        
                        [self.saveButtonItem setEnabled:YES];
                    }];
                    
                } else {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [self.activityIndicator stopAnimating];
                        self.informationLabel.text = @"User not found...";
                    }];
                }
            }
        }];
    }
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self checkIfUserExists];
    
    return YES;
}


#pragma mark - UI Actions

- (IBAction)backgroundTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([self.usernameTextField.text isEqualToString:@""]) {
        return;
    }
    
    [self checkIfUserExists];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.defaultUsername.text
                                              forKey:@"defaultAccount"];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
