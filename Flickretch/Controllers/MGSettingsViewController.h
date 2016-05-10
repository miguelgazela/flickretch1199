//
//  SettingsViewController.h
//  Flickretch
//
//  Created by Miguel Oliveira on 10/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGSettingsViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *defaultUsername;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

@end
